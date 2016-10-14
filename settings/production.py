import os

import dj_database_url

from settings.base import *

SECRET_KEY = os.environ.get('DJANGO_SECRET_KEY', 'set this in heroku')
DEBUG = False
ALLOWED_HOSTS = [os.environ.get('DJANGO_ALLOWED_HOST', '*')]

# Parse database configuration from $DATABASE_URL
DATABASES['default'] = dj_database_url.config()
DATABASES['default']['ENGINE'] = 'django_postgrespool'

# Celery
BROKER_URL = os.environ.get('REDIS_URL', '')
BROKER_POOL_LIMIT = 1
CELERY_TASK_SERIALIZER = 'json'
CELERY_ACCEPT_CONTENT = ['json']

# OPBEAT
INSTALLED_APPS += ["opbeat.contrib.django", ]

OPBEAT = {
    "ORGANIZATION_ID": os.environ.get('OPBEAT_ORG_ID', ''),
    "APP_ID": os.environ.get('OPBEAT_APP_ID', ''),
    "SECRET_TOKEN": os.environ.get('OPBEAT_SECRET_TOKEN', ''),
}

MIDDLEWARE_CLASSES = [
    'opbeat.contrib.django.middleware.OpbeatAPMMiddleware',
    'sslify.middleware.SSLifyMiddleware',
] + MIDDLEWARE_CLASSES

LOGGING = {
    'version': 1,
    'disable_existing_loggers': True,
    'formatters': {
        'verbose': {
            'format':
            '%(levelname)s %(asctime)s %(module)s %(process)d %(thread)d %(message)s'
        },
    },
    'handlers': {
        'opbeat': {
            'level': 'WARNING',
            'class': 'opbeat.contrib.django.handlers.OpbeatHandler',
        },
        'console': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',
            'formatter': 'verbose'
        }
    },
    'loggers': {
        'django.db.backends': {
            'level': 'ERROR',
            'handlers': ['console'],
            'propagate': False,
        },
        'elvanto_sync': {
            'level': 'INFO',
            'handlers': [
                'opbeat',
                'console',
            ],
            'propagate': False,
        },
        # Log errors from the Opbeat module to the console (recommended)
        'opbeat.errors': {
            'level': 'ERROR',
            'handlers': ['console'],
            'propagate': False,
        },
    },
}

# Security:
MIDDLEWARE_CLASSES = MIDDLEWARE_CLASSES + [
    'django.middleware.security.SecurityMiddleware',
]
# CSRF_COOKIE_SECURE = True
# CSRF_COOKIE_HTTPONLY = True
X_FRAME_OPTIONS = 'DENY'
SESSION_COOKIE_SECURE = True
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_BROWSER_XSS_FILTER = True
SECURE_SSL_REDIRECT = True
