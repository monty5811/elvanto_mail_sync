web: bin/start-nginx gunicorn -c gunicorn.conf elvanto_sync.wsgi:application --log-file -
worker: celery -A elvanto_sync worker -l info
