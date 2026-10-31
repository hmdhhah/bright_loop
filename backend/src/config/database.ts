import pg from 'pg';
import { positiveInteger } from './env.js';
let pool: pg.Pool | undefined;
export function getPool(): pg.Pool {
  if (!process.env.DATABASE_URL) throw new Error('DATABASE_URL is required for database operations');
  if (process.env.DB_SSL && !['true', 'false'].includes(process.env.DB_SSL)) throw new Error('DB_SSL must be true or false');
  pool ??= new pg.Pool({ connectionString: process.env.DATABASE_URL, max: positiveInteger(process.env.DB_POOL_MAX, 10), connectionTimeoutMillis: 5000, idleTimeoutMillis: 30000, ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: true } : false });
  return pool;
}
export async function closePool() { if (pool) { await pool.end(); pool = undefined; } }
