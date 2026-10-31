import type { ServerResponse } from 'node:http';
import type { ApiSuccess, ApiError } from '../types/api.js';
export function respond(res: ServerResponse, status: number, body: ApiSuccess<unknown> | ApiError) {
  res.writeHead(status, { 'Content-Type': 'application/json; charset=utf-8', 'Cache-Control': 'no-store', 'X-Content-Type-Options': 'nosniff' });
  res.end(JSON.stringify(body));
}
