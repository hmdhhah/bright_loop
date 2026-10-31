export function positiveInteger(value: string | undefined, fallback: number): number {
  const parsed = value === undefined ? fallback : Number(value);
  if (!Number.isSafeInteger(parsed) || parsed <= 0) throw new Error('Expected a positive integer configuration value');
  return parsed;
}
export function readConfig(env: NodeJS.ProcessEnv = process.env) {
  const port = positiveInteger(env.PORT, 5000);
  if (port > 65535) throw new Error('PORT must be at most 65535');
  return { port, host: env.HOST ?? '127.0.0.1', origins: (env.CORS_ORIGINS ?? 'http://localhost:5173,http://127.0.0.1:5173').split(',').map(s => s.trim()).filter(Boolean) };
}
