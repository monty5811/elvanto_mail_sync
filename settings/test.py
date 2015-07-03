from settings.base import *

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(BASE_DIR, '..', 'test.sqlite3'),
    }
}

CELERY_ALWAYS_EAGER = True
BROKER_BACKEND = 'memory'
TEST_RUNNER = 'djcelery.contrib.test_runner.CeleryTestSuiteRunner'

EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

STATICFILES_STORAGE = 'django.contrib.staticfiles.storage.StaticFilesStorage'

ELVANTO_PEOPLE_PAGE_SIZE = 10
