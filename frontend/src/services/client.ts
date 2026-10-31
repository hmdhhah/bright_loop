import type { ApiResponse } from '../types/api';
export class ApiError extends Error {
  constructor(message: string, public status: number, public code: string, public requestId?: string) { super(message); }
}
export async function request<T>(baseUrl: string, path: string, options: RequestInit = {}): Promise<T> {
  const response = await fetch(`${baseUrl.replace(/\/$/, '')}${path}`, { ...options, credentials: 'include', headers: { Accept: 'application/json', ...(options.body ? { 'Content-Type': 'application/json' } : {}), ...options.headers } });
  const body = await response.json().catch(() => { throw new ApiError('The API returned an invalid response', response.status, 'INVALID_RESPONSE'); });
  if (!response.ok) throw new ApiError(body?.error?.message ?? 'Request failed', response.status, body?.error?.code ?? 'REQUEST_FAILED', body?.meta?.requestId);
  if (!body || typeof body !== 'object' || !('data' in body)) throw new ApiError('Missing API response data', response.status, 'INVALID_RESPONSE');
  return (body as ApiResponse<T>).data;
}
