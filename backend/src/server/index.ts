import { createApp } from './app.js';
import { readConfig } from '../config/env.js';
import { closePool } from '../config/database.js';
const config = readConfig();
const server = createApp(config);
server.listen(config.port, config.host, () => console.log(`Brightloop API listening on http://${config.host}:${config.port}`));
server.on('error', () => { console.error('API server failed to start'); process.exitCode = 1; });
for (const signal of ['SIGINT', 'SIGTERM']) process.once(signal, () => {
  const timeout = setTimeout(() => process.exit(1), 10000); timeout.unref();
  server.close(() => { void closePool().then(() => { clearTimeout(timeout); }); });
});
