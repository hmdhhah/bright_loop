"""Phase 1 entry point. No jobs are claimed or invoices generated yet."""
import argparse
import os
from repositories.database import check_connection
from scheduler.config import poll_seconds

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check-db', action='store_true', help='Test PostgreSQL connectivity and exit')
    args = parser.parse_args()
    poll_seconds(os.environ.get('BILLING_POLL_SECONDS', '30'))
    if args.check_db:
        check_connection()
        print('PostgreSQL connection successful')
    else:
        print('Brightloop billing worker skeleton ready. Scheduler is not implemented; no billing operations performed.')

if __name__ == '__main__':
    main()
