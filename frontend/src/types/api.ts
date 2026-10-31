export type Health = { status: 'ok'; service: string; timestamp: string; database: 'not_checked' };
export type ApiResponse<T> = { data: T; meta: { requestId: string } };
