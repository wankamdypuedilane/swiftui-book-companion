// Contract tests of the StreetPatch routes:  node --test book-api/test/
'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const { server } = require('../server');

let base;
test.before(async () => {
  await new Promise((resolve) => server.listen(0, resolve));
  base = `http://localhost:${server.address().port}/streetpatch/v1`;
});
test.after(() => server.close());

async function call(method, path, { token, body, headers = {} } = {}) {
  const init = { method, headers: { ...headers } };
  if (token) init.headers.Authorization = `Bearer ${token}`;
  if (body !== undefined && !(body instanceof Uint8Array)) {
    init.body = JSON.stringify(body);
    init.headers['Content-Type'] = 'application/json';
  } else if (body) init.body = body;
  const response = await fetch(base + path, init);
  const text = response.headers.get('content-type')?.includes('json')
    ? await response.json()
    : null;
  return { status: response.status, body: text };
}
const signIn = async (email) =>
  (await call('POST', '/auth/token', { body: { email, password: 'local-only-demo-password' } }))
    .body;
const draft = {
  title: 'Broken bench in the square',
  details: 'One slat is missing.',
  category: 'other',
  latitude: 48.3901,
  longitude: -4.485,
};

test('anyone can list reports, newest first, without authors', async () => {
  const { status, body } = await call('GET', '/reports');
  assert.equal(status, 200);
  assert.ok(body.items.length >= 8);
  assert.ok(body.items.every((r) => !('author' in r) && r.isMine === false));
  const dates = body.items.map((r) => Date.parse(r.updatedAt));
  assert.deepEqual(
    dates,
    [...dates].sort((a, b) => b - a),
  );
});

test('filters by status, category and distance', async () => {
  const open = await call('GET', '/reports?status=submitted,acknowledged');
  assert.ok(open.body.items.every((r) => ['submitted', 'acknowledged'].includes(r.status)));
  const lights = await call('GET', '/reports?category=streetlight');
  assert.ok(
    lights.body.items.length > 0 &&
      lights.body.items.every((r) => r.category === 'streetlight'),
  );
  const near = await call('GET', '/reports?near=48.3905,-4.4861&radius=50');
  assert.deepEqual(
    near.body.items.map((r) => r.title),
    ['Deep pothole at the bus stop'],
  );
});

test('creating a report needs a token, an idempotency key and valid fields', async () => {
  assert.equal((await call('POST', '/reports', { body: draft })).status, 401);
  const { accessToken: token, role } = await signIn('resident@streetpatch.example');
  assert.equal(role, 'resident');
  assert.equal((await call('POST', '/reports', { token, body: draft })).status, 400);
  const outside = await call('POST', '/reports', {
    token,
    body: { ...draft, latitude: 48.0 },
    headers: { 'Idempotency-Key': 'k-out' },
  });
  assert.equal(outside.status, 422);
  assert.equal(outside.body.field, 'location');
  const first = await call('POST', '/reports', {
    token,
    body: draft,
    headers: { 'Idempotency-Key': 'k1' },
  });
  assert.equal(first.status, 201);
  assert.equal(first.body.status, 'submitted');
  assert.equal(first.body.isMine, true);
  const replay = await call('POST', '/reports', {
    token,
    body: draft,
    headers: { 'Idempotency-Key': 'k1' },
  });
  assert.equal(replay.status, 200);
  assert.equal(replay.body.id, first.body.id); // no duplicate
});

test('only the author adds a photo, as a JPEG of at most 2 MB', async () => {
  const { accessToken: token } = await signIn('resident@streetpatch.example');
  const created = await call('POST', '/reports', {
    token,
    body: draft,
    headers: { 'Idempotency-Key': 'k-photo' },
  });
  const path = `/reports/${created.body.id}/photo`;
  const jpeg = new Uint8Array([0xff, 0xd8, 0xff, 0xe0, 1, 2, 3]);
  const { accessToken: other } = await signIn('demo@verdant.example');
  assert.equal(
    (
      await call('PUT', path, {
        token: other,
        body: jpeg,
        headers: { 'Content-Type': 'image/jpeg' },
      })
    ).status,
    403,
  );
  assert.equal(
    (await call('PUT', path, { token, body: jpeg, headers: { 'Content-Type': 'image/png' } }))
      .status,
    415,
  );
  const big = new Uint8Array(2_000_001);
  big[0] = 0xff;
  big[1] = 0xd8;
  assert.equal(
    (await call('PUT', path, { token, body: big, headers: { 'Content-Type': 'image/jpeg' } }))
      .status,
    413,
  );
  assert.equal(
    (await call('PUT', path, { token, body: jpeg, headers: { 'Content-Type': 'image/jpeg' } }))
      .status,
    204,
  );
  assert.equal((await call('GET', `/reports/${created.body.id}`)).body.hasPhoto, true);
});

test('support is idempotent and not allowed on your own report', async () => {
  const { accessToken: token } = await signIn('resident@streetpatch.example');
  const list = await call('GET', '/reports?status=submitted', { token });
  const own = list.body.items.find((r) => r.isMine);
  const other = list.body.items.find((r) => !r.isMine);
  assert.equal((await call('PUT', `/reports/${own.id}/support`, { token })).status, 403);
  const once = await call('PUT', `/reports/${other.id}/support`, { token });
  const twice = await call('PUT', `/reports/${other.id}/support`, { token });
  assert.equal(twice.body.supportCount, once.body.supportCount);
  const removed = await call('DELETE', `/reports/${other.id}/support`, { token });
  assert.equal(removed.body.supportCount, once.body.supportCount - 1);
  assert.equal(removed.body.supportedByMe, false);
});

test('staff move reports through the allowed statuses only', async () => {
  const { accessToken: resident } = await signIn('resident@streetpatch.example');
  const { accessToken: staff, role } = await signIn('staff@streetpatch.example');
  assert.equal(role, 'staff');
  const created = await call('POST', '/reports', {
    token: resident,
    body: draft,
    headers: { 'Idempotency-Key': 'k-flow' },
  });
  const path = `/reports/${created.body.id}/status`;
  assert.equal(
    (await call('PATCH', path, { token: resident, body: { status: 'acknowledged' } })).status,
    403,
  );
  assert.equal(
    (await call('PATCH', path, { token: staff, body: { status: 'resolved' } })).status,
    409,
  );
  const step = await call('PATCH', path, {
    token: staff,
    body: { status: 'acknowledged', note: 'Crew booked.' },
  });
  assert.equal(step.status, 200);
  assert.deepEqual(
    step.body.history.map((h) => h.status),
    ['submitted', 'acknowledged'],
  );
  // Once acknowledged, the author can no longer withdraw it.
  assert.equal(
    (await call('DELETE', `/reports/${created.body.id}`, { token: resident })).status,
    409,
  );
});

test('the author withdraws a report that is still submitted', async () => {
  const { accessToken: token } = await signIn('resident@streetpatch.example');
  const created = await call('POST', '/reports', {
    token,
    body: draft,
    headers: { 'Idempotency-Key': 'k-del' },
  });
  assert.equal((await call('DELETE', `/reports/${created.body.id}`, { token })).status, 204);
  assert.equal((await call('GET', `/reports/${created.body.id}`)).status, 404);
});
