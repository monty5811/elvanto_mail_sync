import os

import dj_database_url

from settings.base import *

SECRET_KEY = os.environ.get('DJANGO_SECRET_KEY', 'set this in heroku')
DEBUG = False
ALLOWED_HOSTS = [os.environ.get('DJANGO_ALLOWED_HOST', '*')]

# Templates
TEMPLATES[0]['OPTIONS']['loaders'] = [
    (
        'django.template.loaders.cached.Loader', [
            'django.template.loaders.filesystem.Loader',
            'django.template.loaders.app_directories.Loader',
        ]
    ),
]

# Parse database configuration from $DATABASE_URL
DATABASES['default'] = dj_database_url.config()
DATABASES['default']['ENGINE'] = 'django_postgrespool'

# Celery
CELERY_BROKER_URL = os.environ.get('REDIS_URL', '')
CELERY_BROKER_POOL_LIMIT = 1
CELERY_TASK_SERIALIZER = 'json'
CELERY_ACCEPT_CONTENT = ['json']

# rollbar
MIDDLEWARE = [
    'rollbar.contrib.django.middleware.RollbarNotifierMiddleware',
] + MIDDLEWARE

ROLLBAR = {
    'access_token': os.environ.get('ROLLBAR_ACCESS_TOKEN'),
    'environment': 'development' if DEBUG else 'production',
    'branch': 'master',
    'root': BASE_DIR,
}

ROLLBAR['patch_debugview'] = False

# Logging
LOGGING = {
    'version': 1,
    'disable_existing_loggers': True,
    'formatters': {
        'verbose': {
            'format':
            '%(levelname)s %(asctime)s %(module)s %(process)d %(thread)d %(message)s'
        },
    },
    'filters': {
        'require_debug_false': {
            '()': 'django.utils.log.RequireDebugFalse',
        }
    },
    'handlers': {
        'rollbar': {
            'level': 'WARNING',
            'filters': ['require_debug_false'],
            'access_token': os.environ.get('ROLLBAR_ACCESS_TOKEN'),
            'environment': 'development' if DEBUG else 'production',
            'class': 'rollbar.logger.RollbarHandler'
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
                'rollbar',
                'console',
            ],
            'propagate': False,
        },
    },
}

# Security

# CSRF_COOKIE_SECURE = True
# CSRF_COOKIE_HTTPONLY = True
X_FRAME_OPTIONS = 'DENY'
SESSION_COOKIE_SECURE = True
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_BROWSER_XSS_FILTER = True
SECURE_SSL_REDIRECT = True
