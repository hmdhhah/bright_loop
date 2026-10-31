import { createContext, useCallback, useEffect, useRef, useState, type ReactNode } from 'react';
import { getHealth } from '../services/api';
import type { Health } from '../types/api';
type State = { loading: boolean; health?: Health; error?: string; refresh: () => void };
export const HealthContext = createContext<State | undefined>(undefined);
export function HealthProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<Omit<State, 'refresh'>>({ loading: true });
  const active = useRef<AbortController | null>(null);
  const refresh = useCallback(() => {
    active.current?.abort();
    const controller = new AbortController(); active.current = controller;
    setState({ loading: true });
    const timeout = setTimeout(() => controller.abort(new Error('Connection timed out')), 8000);
    void getHealth(controller.signal).then(health => {
      if (active.current === controller) setState({ loading: false, health });
    }).catch((error: unknown) => {
      if (active.current === controller) setState({ loading: false, error: error instanceof Error ? error.message : 'Unable to reach the API' });
    }).finally(() => clearTimeout(timeout));
  }, []);
  useEffect(() => { refresh(); return () => { const controller = active.current; active.current = null; controller?.abort(); }; }, [refresh]);
  return <HealthContext.Provider value={{ ...state, refresh }}>{children}</HealthContext.Provider>;
}
