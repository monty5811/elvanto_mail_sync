import pytest
import vcr

from django.contrib.auth.models import User
from django.test import Client


@pytest.fixture()
def users():
    user = User.objects.create_user(username='test', email='test@example.com', password='top_secret')
    user.save()
    return {'user': user}


@pytest.mark.usefixtures('users')
@pytest.fixture()
def clients(users):
    c_in = Client()
    c_in.login(username='test', password='top_secret')
    c_out = Client()
    return {'c_in': c_in, 'c_out': c_out}


base_vcr = vcr.VCR(record_mode='none', ignore_localhost=True)
elvanto_vcr = base_vcr.use_cassette(
    'elvanto_sync/tests/fixtures/elvanto.yaml',
    filter_headers=['authorization'],
    match_on=['method', 'scheme', 'host', 'port', 'path', 'query', 'body']
)
