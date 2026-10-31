export function health() { return { status: 'ok', service: 'brightloop-api', timestamp: new Date().toISOString(), database: 'not_checked' }; }
