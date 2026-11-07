// Demonstration API for "Mastering Swift and SwiftUI" (Verdant and StreetPatch).
// Plain Node.js (20 or later), no dependencies:   node server.js
// Everything is kept in memory and reset when the server restarts.
// The demo account and secrets below are for LOCAL DEVELOPMENT ONLY.
'use strict';
const http = require('node:http');
const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');

const PORT = Number(process.env.PORT || 8080);
const TOKEN_TTL = Number(process.env.TOKEN_TTL || 900);           // seconds
const DEMO_USERS = new Map([
  ['demo@verdant.example', 'local-only-demo-password'],           // LOCAL ONLY
  ['resident@streetpatch.example', 'local-only-demo-password'],   // LOCAL ONLY
  ['staff@streetpatch.example', 'local-only-demo-password'],      // LOCAL ONLY
]);
const load = (file) => JSON.parse(fs.readFileSync(path.join(__dirname, 'data', file), 'utf8'));
const species = load('species.json');
const places = load('places.json');
const streetpatch = require('./streetpatch');

// ---------- tokens ----------------------------------------------------------
const accessTokens = new Map();   // token -> { email, expiresAt }
const refreshTokens = new Map();  // token -> email
function issueTokens(email) {
  const accessToken = crypto.randomBytes(24).toString('hex');
  const refreshToken = crypto.randomBytes(24).toString('hex');
  accessTokens.set(accessToken, { email, expiresAt: Date.now() + TOKEN_TTL * 1000 });
  refreshTokens.set(refreshToken, email);
  return { accessToken, refreshToken, expiresIn: TOKEN_TTL, email };
}
function authenticatedEmail(req) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  const entry = token && accessTokens.get(token);
  if (!entry || entry.expiresAt < Date.now()) return null;
  return entry.email;
}

// ---------- helpers ---------------------------------------------------------
// ISO 8601 without fractional seconds ("2026-11-07T18:30:00Z"), the format that
// Swift's JSONDecoder .iso8601 strategy accepts.
const isoDate = (date) => date.toISOString().replace(/\.\d{3}Z$/, 'Z');
function send(res, status, body) {
  if (status === 204) { res.writeHead(204); return res.end(); }
  const json = JSON.stringify(body);
  res.writeHead(status, { 'Content-Type': 'application/json; charset=utf-8',
                          'Content-Length': Buffer.byteLength(json) });
  res.end(json);
}
function readJSON(req) {
  return new Promise((resolve) => {
    let raw = '';
    req.on('data', (chunk) => { raw += chunk; if (raw.length > 5e6) req.destroy(); });
    req.on('end', () => { try { resolve(raw ? JSON.parse(raw) : null); } catch { resolve(undefined); } });
  });
}
function paginate(items, query) {
  const perPage = Math.min(Math.max(parseInt(query.get('perPage') || '20', 10) || 20, 1), 50);
  const totalPages = Math.max(1, Math.ceil(items.length / perPage));
  const page = Math.max(parseInt(query.get('page') || '1', 10) || 1, 1);
  return { items: items.slice((page - 1) * perPage, page * perPage), page, perPage,
           total: items.length, totalPages };
}

// Simulated failures, used by the book's examples and tests:
//   X-Simulate-Status: 503      always answer with this status
//   X-Fail-Times: 2 + X-Request-Key: abc   fail twice with 503 for this key, then succeed
//   ?delay=1500                 wait before answering (milliseconds)
const failureCounts = new Map();
function simulated(req, query) {
  const forced = req.headers['x-simulate-status'];
  if (forced) return Number(forced);
  const times = Number(req.headers['x-fail-times'] || 0);
  const key = req.headers['x-request-key'];
  if (times > 0 && key) {
    const seen = failureCounts.get(key) || 0;
    failureCounts.set(key, seen + 1);
    if (seen < times) return 503;
  }
  return null;
}

// ---------- Verdant routes --------------------------------------------------
const gardens = new Map();       // email -> [Plant]
async function verdant(req, res, route, query) {
  if (req.method === 'GET' && route === '/species') {
    const q = (query.get('q') || '').toLowerCase();
    const light = query.get('light');
    const matches = species.filter((s) =>
      (!q || s.commonName.toLowerCase().includes(q) || s.scientificName.toLowerCase().includes(q)) &&
      (!light || s.light === light))
      .sort((a, b) => a.commonName.localeCompare(b.commonName));
    return send(res, 200, paginate(matches, query));
  }
  let m;
  if (req.method === 'GET' && (m = route.match(/^\/species\/([\w-]+)$/))) {
    const item = species.find((s) => s.id === m[1]);
    return item ? send(res, 200, item) : send(res, 404, { error: 'Unknown species.' });
  }
  if (req.method === 'GET' && route === '/places') return send(res, 200, places);
  if (req.method === 'POST' && route === '/auth/token') {
    const body = await readJSON(req);
    if (!body || typeof body.email !== 'string' || typeof body.password !== 'string')
      return send(res, 400, { error: 'E-mail and password are required.' });
    if (DEMO_USERS.get(body.email.toLowerCase()) !== body.password)
      return send(res, 401, { error: 'Wrong e-mail or password.' });
    return send(res, 200, issueTokens(body.email.toLowerCase()));
  }
  if (req.method === 'POST' && route === '/auth/refresh') {
    const body = await readJSON(req);
    const email = body && refreshTokens.get(body.refreshToken);
    if (!email) return send(res, 401, { error: 'Invalid refresh token.' });
    refreshTokens.delete(body.refreshToken);                 // refresh tokens are single-use
    return send(res, 200, issueTokens(email));
  }
  if (route === '/me/garden') {
    const email = authenticatedEmail(req);
    if (!email) return send(res, 401, { error: 'Authentication required.' });
    if (req.method === 'GET') return send(res, 200, gardens.get(email) || []);
    if (req.method === 'PUT') {
      const body = await readJSON(req);
      if (!Array.isArray(body)) return send(res, 400, { error: 'Expected an array of plants.' });
      gardens.set(email, body);
      return send(res, 200, { plantCount: body.length, savedAt: isoDate(new Date()) });
    }
  }
  return send(res, 404, { error: 'Not found.' });
}

// ---------- server ----------------------------------------------------------
const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  const delay = Math.min(Number(url.searchParams.get('delay') || 0), 10000);
  if (delay) await new Promise((r) => setTimeout(r, delay));
  const failure = simulated(req, url.searchParams);
  if (failure) return send(res, failure, { error: `Simulated ${failure}.` });
  try {
    if (url.pathname === '/health') return send(res, 200, { status: 'ok' });
    if (url.pathname.startsWith('/verdant/v1/'))
      return await verdant(req, res, url.pathname.slice('/verdant/v1'.length), url.searchParams);
    if (url.pathname.startsWith('/streetpatch/v1/'))
      return await streetpatch.handle(req, res, url.pathname.slice('/streetpatch/v1'.length),
                                      url.searchParams, { send, readJSON, paginate,
                                                          authenticatedEmail, issueTokens,
                                                          DEMO_USERS, refreshTokens, isoDate });
    return send(res, 404, { error: 'Not found.' });
  } catch (error) {
    console.error(error);
    return send(res, 500, { error: 'Internal error.' });
  }
});

if (require.main === module) {
  server.listen(PORT, () => console.log(`book-api listening on http://localhost:${PORT}`));
}
module.exports = { server, isoDate };
