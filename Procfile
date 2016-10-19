web: gunicorn elvanto_sync.wsgi:application --log-file -
worker: celery -A elvanto_sync worker -l info
