import { request } from './client';
import type { Health } from '../types/api';
export const apiUrl = import.meta.env.VITE_API_URL || 'http://localhost:5000';
export const getHealth = (signal: AbortSignal) => request<Health>(apiUrl, '/api/health', { signal });
