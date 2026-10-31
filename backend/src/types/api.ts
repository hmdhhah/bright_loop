export type ApiSuccess<T> = { data: T; meta: { requestId: string } };
export type ApiError = { error: { code: string; message: string }; meta: { requestId: string } };
