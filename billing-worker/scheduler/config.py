def poll_seconds(value: str) -> int:
    result = int(value)
    if result <= 0:
        raise ValueError('BILLING_POLL_SECONDS must be a positive integer')
    return result
