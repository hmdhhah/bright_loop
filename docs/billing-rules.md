# Billing rules — planned, not implemented

Python owns all monetary calculation and recurring invoice generation. Use Decimal and PostgreSQL NUMERIC; exchange monetary values as decimal strings, never binary floats. Before Phase 7, agree on currency precision, rounding, tax inclusivity, discount order and shared fixtures.

Billing timestamps are UTC. The planned initial schedule uses UTC calendar boundaries; monthly/yearly periods must preserve an anchor day and explicitly handle month ends and leap years. No local-time or daylight-saving conversion is currently implemented.

Future worker: claim due rows with transaction-scoped `FOR UPDATE SKIP LOCKED`, generate immutable invoice snapshots and redemptions atomically, enforce subscription-period uniqueness, advance schedules only on success, and record retry state with bounded exponential backoff. A crash must roll back the invoice and schedule together. Payment allocations need locks and constraints to prevent over-allocation. These rules are design requirements, not current guarantees.
