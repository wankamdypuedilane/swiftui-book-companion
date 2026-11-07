// StreetPatch routes (Chapter 25), mounted under /streetpatch/v1.
// Residents of the fictional town of Kerbrume report problems in public space;
// the town's staff acknowledge, schedule and resolve them.
// Everything is kept in memory and reset when the server restarts.
'use strict';

const CATEGORIES = ['pothole', 'streetlight', 'graffiti', 'litter', 'drain', 'signage', 'other'];
const STAFF = new Set(['staff@streetpatch.example']);   // LOCAL ONLY demo account
// Allowed status changes: the same rule as ReportStatus.canMove(to:) in StreetPatchKit.
const TRANSITIONS = {
  submitted: ['acknowledged', 'rejected'],
  acknowledged: ['inProgress', 'rejected'],
  inProgress: ['resolved'],
  resolved: [],
  rejected: [],
};
// The service area: a rectangle around Kerbrume.
const AREA = { minLatitude: 48.37, maxLatitude: 48.42, minLongitude: -4.53, maxLongitude: -4.43 };
const MAX_PHOTO_BYTES = 2_000_000;

const reports = new Map();        // id -> stored report (with author e-mail)
const photos = new Map();         // id -> Buffer (JPEG)
const idempotency = new Map();    // "email|key" -> report id
let nextNumber = 1;

function seed() {
  const now = Date.now();
  const hours = (n) => new Date(now - n * 3_600_000);
  const rows = [
    ['Deep pothole at the bus stop', 'pothole', 'inProgress', 48.3905, -4.4861, 50, 'resident@streetpatch.example'],
    ['Streetlight out on Quai des Brumes', 'streetlight', 'acknowledged', 48.3871, -4.4790, 30, 'neighbour@streetpatch.example'],
    ['Graffiti on the library wall', 'graffiti', 'submitted', 48.3932, -4.4902, 6, 'neighbour@streetpatch.example'],
    ['Overflowing bins after the market', 'litter', 'resolved', 48.3889, -4.4825, 120, 'resident@streetpatch.example'],
    ['Blocked drain floods the crossing', 'drain', 'submitted', 48.3954, -4.4757, 3, 'neighbour@streetpatch.example'],
    ['Stop sign turned sideways', 'signage', 'rejected', 48.3840, -4.4930, 200, 'neighbour@streetpatch.example'],
    ['Loose paving stones near the school', 'pothole', 'submitted', 48.3918, -4.4801, 1, 'neighbour@streetpatch.example'],
    ['Flickering lamp in Parc du Phare', 'streetlight', 'submitted', 48.3976, -4.4885, 12, 'resident@streetpatch.example'],
  ];
  for (const [title, category, status, latitude, longitude, age, author] of rows) {
    const created = hours(age);
    const report = store({ title, details: '', category, latitude, longitude, author, created });
    const path = ['submitted'];
    while (path[path.length - 1] !== status) {
      const next = { submitted: 'acknowledged', acknowledged: 'inProgress', inProgress: 'resolved' };
      path.push(status === 'rejected' && path.length === 1 ? 'rejected' : next[path[path.length - 1]]);
    }
    path.slice(1).forEach((s, i) => {
      report.history.push({ status: s, at: new Date(created.getTime() + (i + 1) * 3_600_000), note: null });
    });
    report.status = status;
    report.updatedAt = report.history[report.history.length - 1].at;
    report.supporters = new Set(age < 24 ? [] : ['someone@streetpatch.example']);
  }
}

function store({ title, details, category, latitude, longitude, author, created }) {
  const id = `KB-${String(nextNumber++).padStart(4, '0')}`;
  const report = {
    id, title, details, category, latitude, longitude, author,
    status: 'submitted', createdAt: created, updatedAt: created,
    history: [{ status: 'submitted', at: created, note: null }],
    supporters: new Set(),
  };
  reports.set(id, report);
  return report;
}

// The public view of a report. The author's e-mail never leaves the server:
// the client only learns whether the report is its own.
function view(report, email, isoDate) {
  return {
    id: report.id, title: report.title, details: report.details, category: report.category,
    status: report.status, latitude: report.latitude, longitude: report.longitude,
    createdAt: isoDate(report.createdAt), updatedAt: isoDate(report.updatedAt),
    supportCount: report.supporters.size,
    supportedByMe: !!email && report.supporters.has(email),
    isMine: !!email && report.author === email,
    hasPhoto: photos.has(report.id),
    history: report.history.map((h) => ({ status: h.status, at: isoDate(h.at), note: h.note })),
  };
}

// Returns an error message, or null when the new report is acceptable.
function invalid(body) {
  if (!body || typeof body !== 'object') return ['body', 'Expected a JSON object.'];
  const title = typeof body.title === 'string' ? body.title.trim() : '';
  if (title.length < 5 || title.length > 80) return ['title', 'The title needs 5 to 80 characters.'];
  if (body.details != null && (typeof body.details !== 'string' || body.details.length > 1000))
    return ['details', 'The details are limited to 1,000 characters.'];
  if (!CATEGORIES.includes(body.category)) return ['category', 'Unknown category.'];
  const { latitude, longitude } = body;
  if (typeof latitude !== 'number' || typeof longitude !== 'number' ||
      latitude < AREA.minLatitude || latitude > AREA.maxLatitude ||
      longitude < AREA.minLongitude || longitude > AREA.maxLongitude)
    return ['location', 'This place is outside Kerbrume.'];
  return null;
}

function distanceInMetres(a, b) {   // haversine formula
  const rad = (d) => (d * Math.PI) / 180;
  const dLat = rad(b.latitude - a.latitude), dLon = rad(b.longitude - a.longitude);
  const h = Math.sin(dLat / 2) ** 2 +
    Math.cos(rad(a.latitude)) * Math.cos(rad(b.latitude)) * Math.sin(dLon / 2) ** 2;
  return 2 * 6_371_000 * Math.asin(Math.sqrt(h));
}

function readBytes(req, limit) {
  return new Promise((resolve) => {
    const chunks = []; let size = 0;
    req.on('data', (chunk) => {
      size += chunk.length;
      if (size <= limit) chunks.push(chunk);
    });
    req.on('end', () => resolve(size > limit ? null : Buffer.concat(chunks)));
  });
}

async function handle(req, res, route, query, h) {
  const { send, readJSON, paginate, authenticatedEmail, issueTokens, DEMO_USERS, refreshTokens,
          isoDate } = h;
  const email = authenticatedEmail(req);
  const requireUser = () => (email ? null : send(res, 401, { error: 'Authentication required.' }));

  // ----- authentication (same contract as Verdant's) -----
  if (req.method === 'POST' && route === '/auth/token') {
    const body = await readJSON(req);
    if (!body || typeof body.email !== 'string' || typeof body.password !== 'string')
      return send(res, 400, { error: 'E-mail and password are required.' });
    const address = body.email.toLowerCase();
    if (DEMO_USERS.get(address) !== body.password)
      return send(res, 401, { error: 'Wrong e-mail or password.' });
    return send(res, 200, { ...issueTokens(address), role: STAFF.has(address) ? 'staff' : 'resident' });
  }
  if (req.method === 'POST' && route === '/auth/refresh') {
    const body = await readJSON(req);
    const address = body && refreshTokens.get(body.refreshToken);
    if (!address) return send(res, 401, { error: 'Invalid refresh token.' });
    refreshTokens.delete(body.refreshToken);
    return send(res, 200, { ...issueTokens(address), role: STAFF.has(address) ? 'staff' : 'resident' });
  }

  // ----- reports -----
  if (route === '/reports' && req.method === 'GET') {
    let items = [...reports.values()];
    const statuses = (query.get('status') || '').split(',').filter(Boolean);
    if (statuses.length) items = items.filter((r) => statuses.includes(r.status));
    const category = query.get('category');
    if (category) items = items.filter((r) => r.category === category);
    if (query.get('mine') === 'true') {
      if (!email) return requireUser();
      items = items.filter((r) => r.author === email);
    }
    const near = (query.get('near') || '').split(',').map(Number);
    if (near.length === 2 && near.every(Number.isFinite)) {
      const radius = Number(query.get('radius') || 1000);
      const centre = { latitude: near[0], longitude: near[1] };
      items = items.filter((r) => distanceInMetres(centre, r) <= radius);
    }
    items.sort((a, b) => b.updatedAt - a.updatedAt || a.id.localeCompare(b.id));
    const page = paginate(items, query);
    return send(res, 200, { ...page, items: page.items.map((r) => view(r, email, isoDate)) });
  }
  if (route === '/reports' && req.method === 'POST') {
    if (!email) return requireUser();
    const key = req.headers['idempotency-key'];
    if (!key || key.length > 64) return send(res, 400, { error: 'An Idempotency-Key header is required.' });
    const known = idempotency.get(`${email}|${key}`);
    if (known && reports.has(known)) return send(res, 200, view(reports.get(known), email, isoDate));
    const body = await readJSON(req);
    const problem = invalid(body);
    if (problem) return send(res, 422, { error: problem[1], field: problem[0] });
    const report = store({
      title: body.title.trim(), details: (body.details || '').trim(), category: body.category,
      latitude: body.latitude, longitude: body.longitude, author: email, created: new Date(),
    });
    idempotency.set(`${email}|${key}`, report.id);
    return send(res, 201, view(report, email, isoDate));
  }

  const m = route.match(/^\/reports\/(KB-\d{4})(\/photo|\/support|\/status)?$/);
  if (!m) return send(res, 404, { error: 'Not found.' });
  const report = reports.get(m[1]);
  if (!report) return send(res, 404, { error: 'Unknown report.' });
  const sub = m[2] || '';

  if (sub === '' && req.method === 'GET') return send(res, 200, view(report, email, isoDate));
  if (sub === '' && req.method === 'DELETE') {
    if (!email) return requireUser();
    if (report.author !== email) return send(res, 403, { error: 'Only the author can withdraw a report.' });
    if (report.status !== 'submitted')
      return send(res, 409, { error: 'A report can be withdrawn only before the town acknowledges it.' });
    reports.delete(report.id); photos.delete(report.id);
    return send(res, 204);
  }
  if (sub === '/photo' && req.method === 'GET') {
    const photo = photos.get(report.id);
    if (!photo) return send(res, 404, { error: 'This report has no photo.' });
    res.writeHead(200, { 'Content-Type': 'image/jpeg', 'Content-Length': photo.length });
    return res.end(photo);
  }
  if (sub === '/photo' && req.method === 'PUT') {
    if (!email) return requireUser();
    if (report.author !== email) return send(res, 403, { error: 'Only the author can add a photo.' });
    if (req.headers['content-type'] !== 'image/jpeg')
      return send(res, 415, { error: 'Photos must be sent as image/jpeg.' });
    const bytes = await readBytes(req, MAX_PHOTO_BYTES);
    if (!bytes) return send(res, 413, { error: 'The photo is larger than 2 MB.' });
    if (bytes.length < 3 || bytes[0] !== 0xff || bytes[1] !== 0xd8)
      return send(res, 415, { error: 'This is not a JPEG image.' });
    photos.set(report.id, bytes);
    return send(res, 204);
  }
  if (sub === '/support' && (req.method === 'PUT' || req.method === 'DELETE')) {
    if (!email) return requireUser();
    if (report.author === email) return send(res, 403, { error: 'You cannot support your own report.' });
    if (req.method === 'PUT') report.supporters.add(email); else report.supporters.delete(email);
    return send(res, 200, { supportCount: report.supporters.size, supportedByMe: req.method === 'PUT' });
  }
  if (sub === '/status' && req.method === 'PATCH') {
    if (!email) return requireUser();
    if (!STAFF.has(email)) return send(res, 403, { error: 'Only town staff can change a status.' });
    const body = await readJSON(req);
    const next = body && body.status;
    if (!(TRANSITIONS[report.status] || []).includes(next))
      return send(res, 409, { error: `A ${report.status} report cannot become ${next}.` });
    const at = new Date();
    report.status = next; report.updatedAt = at;
    report.history.push({ status: next, at, note: typeof body.note === 'string' ? body.note.slice(0, 200) : null });
    return send(res, 200, view(report, email, isoDate));
  }
  return send(res, 405, { error: 'Method not allowed.' });
}

seed();
module.exports = { handle, CATEGORIES, TRANSITIONS, AREA };
