# -*- coding: utf-8 -*-
import os

BASE_DIR = os.path.dirname(os.path.dirname(__file__))
SECRET_KEY = os.environ.get('DJANGO_SECRET_KEY', '')
DEBUG = True
ALLOWED_HOSTS = ['*']

# Application definition

INSTALLED_APPS = [
    # built in
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    # elvanto sync
    'elvanto_sync',
    # 3rd party
    'social.apps.django_app.default',
    'bootstrap3',
    'django_extensions',
    'rest_framework',
]

MIDDLEWARE_CLASSES = [
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.auth.middleware.SessionAuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

TEMPLATE_CONTEXT_PROCESSORS = (
    "django.core.context_processors.request",
    'django.core.context_processors.static',
    'django.contrib.auth.context_processors.auth',
    'django.contrib.messages.context_processors.messages',
    'social.apps.django_app.context_processors.backends',
    'social.apps.django_app.context_processors.login_redirect',
)

AUTHENTICATION_BACKENDS = (
    'social.backends.google.GoogleOAuth2',
    'django.contrib.auth.backends.ModelBackend',
)

ROOT_URLCONF = 'elvanto_sync.urls'

WSGI_APPLICATION = 'elvanto_sync.wsgi.application'

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
    }
}

# Internationalization
LANGUAGE_CODE = 'en-gb'
TIME_ZONE = 'GMT'
USE_I18N = True
USE_L10N = True
USE_TZ = True

# Honor the 'X-Forwarded-Proto' header for request.is_secure()
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')

# Static files (CSS, JavaScript, Images)
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
STATIC_ROOT = 'staticfiles'
STATIC_URL = '/static/'

STATICFILES_DIRS = (
    os.path.join(BASE_DIR, '..', 'elvanto_sync', 'static'),
)

STATICFILES_STORAGE = 'whitenoise.django.GzipManifestStaticFilesStorage'

# Elvanto
ELVANTO_KEY = os.environ.get('ELVANTO_KEY', '')
EMAIL_OVERRIDE_FIELD_ID = os.environ.get('ELVANTO_OVERRIDE_FILED_ID', '')

# social login settings
SOCIAL_AUTH_URL_NAMESPACE = 'social'
SOCIAL_AUTH_LOGIN_REDIRECT_ULR = '/'
SOCIAL_AUTH_MODEL = 'elvanto_sync'
SOCIAL_AUTH_USER_MODEL = 'auth.User'
SOCIAL_AUTH_STRATEGY = 'social.strategies.django_strategy.DjangoStrategy'

LOGIN_URL = '/login/google-oauth2'
LOGIN_ERROR_URL = '/'
LOGIN_REDIRECT_URL = '/'

# Google auth credentials
SOCIAL_AUTH_GOOGLE_OAUTH2_KEY = os.environ.get('SOCIAL_AUTH_GOOGLE_OAUTH2_KEY', '')
SOCIAL_AUTH_GOOGLE_OAUTH2_SECRET = os.environ.get('SOCIAL_AUTH_GOOGLE_OAUTH2_SECRET', '')
SOCIAL_AUTH_GOOGLE_OAUTH2_WHITELISTED_DOMAINS = os.environ.get('SOCIAL_AUTH_GOOGLE_OAUTH2_WHITELISTED_DOMAINS', '').replace('  ', '').split(',')
SOCIAL_AUTH_GOOGLE_OAUTH2_WHITELISTED_EMAILS = os.environ.get('SOCIAL_AUTH_GOOGLE_OAUTH2_WHITELISTED_EMAILS', '').replace(' ', '').split(',')


SOCIAL_AUTH_GOOGLE_OAUTH2_SCOPE = [
    'https://www.googleapis.com/auth/admin.directory.group.member',
    'https://www.googleapis.com/auth/admin.directory.group',
]
SOCIAL_AUTH_GOOGLE_OAUTH2_AUTH_EXTRA_ARGUMENTS = {
    'access_type': 'offline',
    'approval_prompt': 'auto',
}
