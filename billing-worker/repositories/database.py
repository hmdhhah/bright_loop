import os

def check_connection():
    url = os.environ.get('DATABASE_URL')
    if not url:
        raise ValueError('DATABASE_URL is required')
    import psycopg
    with psycopg.connect(url, connect_timeout=5) as connection:
        with connection.cursor() as cursor:
            cursor.execute('SELECT 1')
            assert cursor.fetchone() == (1,)
