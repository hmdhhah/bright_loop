import { useHealth } from '../hooks/useHealth';
import { apiUrl } from '../services/api';
export function ConnectionStatus() {
 const { loading, health, error, refresh } = useHealth();
 return <section className="panel" aria-labelledby="connection-title"><div className="row"><h2 id="connection-title">Backend connection</h2><span className={health ? 'badge success' : 'badge'}>{loading ? 'Checking' : health ? 'Connected' : 'Unavailable'}</span></div><p role="status" aria-live="polite">{loading ? 'Contacting the Brightloop API…' : error ?? `Connected to ${health?.service}`}</p><code>{apiUrl}/api/health</code><p className="muted">This checks API availability. PostgreSQL is checked separately.</p><button onClick={refresh} disabled={loading}>Check connection ↗</button></section>;
}
