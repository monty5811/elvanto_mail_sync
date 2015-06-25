# -*- coding: utf-8 -*-
import pytest
from django.core.urlresolvers import reverse

from elvanto_sync.elvanto import refresh_elvanto_data
from elvanto_sync.models import ElvantoGroup


@pytest.mark.django_db
class TestUrls():
    @pytest.mark.parametrize("url,status_code", [
        (reverse('index'), 302),
    ])
    def test_not_logged_in(self, url, status_code, clients):
        resp = clients['c_out'].get(url)
        assert resp.url.endswith("/login/google-oauth2?next=/")
        assert resp.status_code == status_code

    @pytest.mark.parametrize("url,status_code", [
        (reverse('index'), 200),
        (reverse('api_groups'), 200),
        (reverse('api_persons'), 200),
    ])
    def test_logged_in(self, url, status_code, clients):
        assert clients['c_in'].get(url).status_code == status_code

    @pytest.mark.parametrize("url,status_code", [
        (reverse('group', kwargs={'pk': 1}), 200),
        (reverse('api_person', kwargs={'pk': 1}), 200),
        (reverse('api_group_people', kwargs={'pk': 1}), 200),
    ])
    @pytest.mark.slowtest
    def test_logged_in_db(self, url, status_code, clients):
        refresh_elvanto_data()
        assert clients['c_in'].get(url).status_code == status_code

    @pytest.mark.slowtest
    def test_post_to_group(self, clients):
        pk_ = 1
        refresh_elvanto_data()
        post_data = {
            'google_email': 'test@example.com',
            'push_auto': False,
        }
        resp = clients['c_in'].post(reverse('group', kwargs={'pk': pk_}), post_data)
        assert resp.status_code == 302
        assert resp.url.endswith(reverse('group', kwargs={'pk': pk_}))
        assert ElvantoGroup.objects.get(pk=pk_).google_email == 'test@example.com'

        post_data_invalid = {
            'google_email': 'not_an_email',
            'push_auto': True,
        }
        resp = clients['c_in'].post(reverse('group', kwargs={'pk': pk_}), post_data_invalid)
        assert resp.status_code == 200
        assert ElvantoGroup.objects.get(pk=pk_).google_email == 'test@example.com'
        assert ElvantoGroup.objects.get(pk=pk_).push_auto is False
