import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createApp } from '../src/server/app.js';
import { readConfig } from '../src/config/env.js';
test('health, request IDs, routing and restricted CORS over HTTP', async () => {
  const server = createApp();
  await new Promise<void>(resolve => server.listen(0, '127.0.0.1', resolve));
  try {
    const address = server.address(); assert(address && typeof address !== 'string');
    const base = `http://127.0.0.1:${address.port}`;
    const response = await fetch(`${base}/api/health`, { headers: { Origin: 'http://localhost:5173' } });
    assert.equal(response.status, 200);
    assert.equal(response.headers.get('access-control-allow-origin'), 'http://localhost:5173');
    const body = await response.json(); assert.equal(body.data.status, 'ok'); assert.equal(body.data.database, 'not_checked');
    assert.equal(body.meta.requestId, response.headers.get('x-request-id'));
    const blocked = await fetch(`${base}/api/health`, { headers: { Origin: 'https://untrusted.example' } });
    assert.equal(blocked.status, 403); assert.equal(blocked.headers.get('access-control-allow-origin'), null);
    assert.equal((await fetch(`${base}/api/health`, { method: 'OPTIONS', headers: { Origin: 'http://localhost:5173' } })).status, 204);
    assert.equal((await fetch(`${base}/api/health`, { method: 'POST' })).status, 405);
    const missing = await fetch(`${base}/api/missing`); assert.equal(missing.status, 404); assert.equal((await missing.json()).error.code, 'NOT_FOUND');
  } finally { await new Promise<void>((resolve, reject) => server.close(error => error ? reject(error) : resolve())); }
});
test('invalid ports fail at startup', () => { for (const PORT of ['abc', '0', '65536']) assert.throws(() => readConfig({ PORT })); });
