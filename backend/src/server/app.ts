import { createServer } from 'node:http';
import { randomUUID } from 'node:crypto';
import { readConfig } from '../config/env.js';
import { respond } from '../utils/respond.js';
import { health } from '../controllers/health.js';
export function createApp(config = readConfig()) {
  const server = createServer((req, res) => {
    const requestId = randomUUID();
    const fail = (status: number, code: string, message: string) => respond(res, status, { error: { code, message }, meta: { requestId } });
    res.setHeader('X-Request-ID', requestId);
    res.setHeader('Vary', 'Origin');
    const origin = req.headers.origin;
    if (origin && !config.origins.includes(origin)) { fail(403, 'ORIGIN_NOT_ALLOWED', 'Origin is not allowed'); return; }
    if (origin) { res.setHeader('Access-Control-Allow-Origin', origin); res.setHeader('Access-Control-Allow-Credentials', 'true'); }
    let path: string;
    try { path = new URL(req.url ?? '/', 'http://localhost').pathname; }
    catch { fail(400, 'INVALID_URL', 'Invalid request URL'); return; }
    if (path !== '/api/health') { fail(404, 'NOT_FOUND', 'Route not found'); return; }
    if (req.method === 'OPTIONS') {
      res.writeHead(204, { 'Access-Control-Allow-Methods': 'GET, OPTIONS', 'Access-Control-Allow-Headers': 'Content-Type', 'Access-Control-Max-Age': '600' }); res.end(); return;
    }
    if (req.method !== 'GET') { res.setHeader('Allow', 'GET, OPTIONS'); fail(405, 'METHOD_NOT_ALLOWED', 'Method not allowed'); return; }
    respond(res, 200, { data: health(), meta: { requestId } });
  });
  server.requestTimeout = 15000;
  server.headersTimeout = 10000;
  return server;
}
