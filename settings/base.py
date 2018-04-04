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
    'django.contrib.sites',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.staticfiles',
    # elvanto sync
    'elvanto_sync',
    # 3rd party
    'django_extensions',
    'rest_framework',
    # allauth
    'allauth',
    'allauth.account',
    'allauth.socialaccount',
    'allauth.socialaccount.providers.google',
]

SITE_ID = 1

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'django.middleware.http.ConditionalGetMiddleware',
]

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.request',
                'django.template.context_processors.static',
                'django.contrib.auth.context_processors.auth',
            ],
            'loaders': [
                'django.template.loaders.filesystem.Loader',
                'django.template.loaders.app_directories.Loader',
            ],
        },
    },
]

AUTHENTICATION_BACKENDS = (
    'django.contrib.auth.backends.ModelBackend',
    'allauth.account.auth_backends.AuthenticationBackend',
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

STATICFILES_DIRS = (os.path.join(BASE_DIR, '..', 'elvanto_sync', 'static'), )
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'
STATICFILES_FINDERS = (
    'django.contrib.staticfiles.finders.AppDirectoriesFinder',
)

# Elvanto
ELVANTO_KEY = os.environ.get('ELVANTO_KEY', '')
EMAIL_OVERRIDE_FIELD_ID = os.environ.get('ELVANTO_OVERRIDE_FIELD_ID', '')
ELVANTO_PEOPLE_PAGE_SIZE = 1000  # must be 10 or larger

# login settings
LOGIN_URL = '/auth/google/login/'
LOGIN_ERROR_URL = '/'
LOGIN_REDIRECT_URL = '/'

# Google auth settings
SOCIALACCOUNT_ADAPTER = 'elvanto_sync.adapters.LockedDownGoogleAdapter'
ACCOUNT_EMAIL_REQUIRED = True
ACCOUNT_AUTHENTICATION_METHOD = 'email'

GOOGLE_OAUTH2_WHITELISTED_DOMAINS = os.environ.get(
    'GOOGLE_OAUTH2_WHITELISTED_DOMAINS', None)
if GOOGLE_OAUTH2_WHITELISTED_DOMAINS is not None:
    GOOGLE_OAUTH2_WHITELISTED_DOMAINS.replace('  ', '').split(',')

GOOGLE_OAUTH2_WHITELISTED_EMAILS = os.environ.get(
    'GOOGLE_OAUTH2_WHITELISTED_EMAILS', None
)
if GOOGLE_OAUTH2_WHITELISTED_EMAILS is not None:
    GOOGLE_OAUTH2_WHITELISTED_EMAILS.replace(' ', '').split(',')

# Use a service key to access Google apis:
# see http://gspread.readthedocs.io/en/latest/oauth2.html for help
# you need to download the json file and then copy the entries into the heroku
# settings
GOOGLE_KEYFILE_DICT = {
    'type': os.environ['G_TYPE'],
    'project_id': os.environ['G_PROJECT_ID'],
    'private_key_id': os.environ['G_PRIVATE_KEY_ID'],
    'private_key': os.environ['G_PRIVATE_KEY'],
    'client_email': os.environ['G_CLIENT_EMAIL'],
    'client_id': os.environ['G_CLIENT_ID'],
    'auth_uri': os.environ['G_AUTH_URI'],
    'token_uri': os.environ['G_TOKEN_URI'],
    'auth_provider_x509_cert_url': os.environ['G_AUTH_PROVIDER_X509_CERT_URL'],
    'client_x509_cert_url': os.environ['G_CLIENT_X509_CERT_URL'],
}

G_DELEGATED_USER = os.environ.get('G_DELEGATED_USER')

GOOGLE_AUTH_SCOPE = [
    'https://www.googleapis.com/auth/admin.directory.group.member',
    'https://www.googleapis.com/auth/admin.directory.group',
]
