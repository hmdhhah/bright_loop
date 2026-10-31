import { useContext } from 'react';
import { HealthContext } from '../contexts/HealthContext';
export function useHealth() { const value = useContext(HealthContext); if (!value) throw new Error('HealthProvider is required'); return value; }
