import { getPool, closePool } from './database.js';
try {
    await getPool().query('SELECT 1 AS connected');
    console.log('PostgreSQL connection successful');
}
catch {
    console.error('PostgreSQL connection failed. Check DATABASE_URL and database availability.');
    process.exitCode = 1;
}
finally {
    await closePool();
}
