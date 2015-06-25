web: gunicorn elvanto_sync.wsgi --log-file -
worker: celery -A elvanto_sync worker -l info
