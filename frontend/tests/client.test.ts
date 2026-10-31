import { test } from 'node:test';
import assert from 'node:assert/strict';
import { request, ApiError } from '../src/services/client.ts';
test('API client sends cookies, unwraps responses and exposes structured failures', async () => {
  const original = globalThis.fetch;
  try {
    globalThis.fetch = async (url, init) => { assert.equal(url, 'http://localhost:5000/api/health'); assert.equal(init?.credentials, 'include'); return Response.json({ data: { status: 'ok' }, meta: { requestId: 'test' } }); };
    assert.deepEqual(await request('http://localhost:5000/', '/api/health'), { status: 'ok' });
    globalThis.fetch = async () => Response.json({ error: { code: 'NOT_FOUND', message: 'Route not found' }, meta: { requestId: 'test' } }, { status: 404 });
    await assert.rejects(request('', '/missing'), (error: unknown) => error instanceof ApiError && error.status === 404 && error.code === 'NOT_FOUND' && error.requestId === 'test');
    globalThis.fetch = async () => new Response('not json');
    await assert.rejects(request('', '/'), (error: unknown) => error instanceof ApiError && error.code === 'INVALID_RESPONSE');
  } finally { globalThis.fetch = original; }
});
