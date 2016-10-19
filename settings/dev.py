from settings.base import *

INSTALLED_APPS.insert(
    INSTALLED_APPS.index('django.contrib.staticfiles'),
    'whitenoise.runserver_nostatic',
)

print(INSTALLED_APPS)

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
        'console': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',
            'formatter': 'verbose'
        }
    },
    'loggers': {
        'django': {
            'level': 'ERROR',
            'handlers': ['console'],
            'propagate': False,
        },
        'elvanto_sync': {
            'level': 'INFO',
            'handlers': ['console', ],
            'propagate': False,
        },
    },
}
