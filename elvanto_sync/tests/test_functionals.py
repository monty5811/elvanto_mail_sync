import json
import pytest
from django.core.urlresolvers import reverse

from elvanto_sync.elvanto import refresh_elvanto_data
from elvanto_sync.models import ElvantoGroup, ElvantoPerson
from elvanto_sync.tests.conftest import elvanto_vcr


@pytest.mark.django_db
class TestUrls():
    @pytest.mark.parametrize("url,status_code", [(reverse('index'), 302), ])
    def test_not_logged_in(self, url, status_code, clients):
        resp = clients['c_out'].get(url)
        assert resp.url.endswith("/login/google-oauth2?next=/")
        assert resp.status_code == status_code

    @pytest.mark.parametrize(
        "url,status_code", [
            (reverse('index'), 200),
        ]
    )
    def test_logged_in(self, url, status_code, clients):
        assert clients['c_in'].get(url).status_code == status_code

    @pytest.mark.parametrize(
        "url,status_code", [
            (reverse(
                'api_groups'
            ), 200),
            (reverse(
                'api_people'
            ), 200),
            (reverse(
                'api_person', kwargs={'pk': 1}
            ), 200),
        ]
    )
    @elvanto_vcr
    def test_logged_in_db(self, url, status_code, clients):
        refresh_elvanto_data()
        assert clients['c_in'].get(url).status_code == status_code

    @elvanto_vcr
    def test_button_pull_all(self, clients):
        post_data = {}
        resp = clients['c_in'].post(reverse('button_pull_all'), post_data)
        assert resp.status_code == 200
        calvin = ElvantoPerson.objects.get(
            e_id='f7cfa258-d3c6-11e4-95ba-068b656294b7'
        )
        assert str(calvin) == 'John Calvin'
        assert calvin.email == 'john.calvin@geneva.com'
        chalmers = ElvantoPerson.objects.get(
            e_id='5a0a1cbc-d3c7-11e4-95ba-068b656294b7'
        )
        assert str(chalmers) == 'Thomas Chalmers'
        assert chalmers.email == 'thomas.chalmers@edinburgh.com'
        knox = ElvantoPerson.objects.get(
            e_id='c1136264-d3c7-11e4-95ba-068b656294b7'
        )
        assert str(knox) == 'John Knox'
        assert knox.email == ''
        owen = ElvantoPerson.objects.get(
            e_id='48366137-d3c7-11e4-95ba-068b656294b7'
        )
        assert str(owen) == 'John Owen'
        assert owen.email == 'john.owen@cambridge.com'

    @elvanto_vcr
    def test_button_update_global(self, clients):
        refresh_elvanto_data()
        # ensure Calvin is enabled
        calvin = ElvantoPerson.objects.get(
            e_id='f7cfa258-d3c6-11e4-95ba-068b656294b7'
        )
        assert not calvin.disabled_entirely
        # disable calvin
        post_data = {'pk': calvin.pk, 'disable': True}
        resp = clients['c_in'].generic('POST', reverse('button_update_global'), json.dumps(post_data))
        assert resp.status_code == 200
        calvin.refresh_from_db()
        assert calvin.disabled_entirely
        # re-enable him again
        post_data = {'pk': calvin.pk, 'disable': False}
        resp = clients['c_in'].generic('POST', reverse('button_update_global'), json.dumps(post_data))
        assert resp.status_code == 200
        calvin.refresh_from_db()
        assert not calvin.disabled_entirely

    @elvanto_vcr
    def test_button_update_local(self, clients):
        refresh_elvanto_data()
        # ensure Calvin is enabled in Geneva
        calvin = ElvantoPerson.objects.get(
            e_id='f7cfa258-d3c6-11e4-95ba-068b656294b7'
        )
        geneva_grp = ElvantoGroup.objects.get(name='Geneva')
        assert geneva_grp not in calvin.disabled_groups.all()
        # disable calvin in group
        post_data = {
            'p_id': calvin.pk,
            'g_id': geneva_grp.pk,
            'disable': False,
        }
        resp = clients['c_in'].generic('POST', reverse('button_update_local'), json.dumps(post_data))
        assert resp.status_code == 200
        geneva_grp.refresh_from_db()
        assert geneva_grp in calvin.disabled_groups.all()
        # re-enable him again
        post_data = {
            'p_id': calvin.pk,
            'g_id': geneva_grp.pk,
            'disable': True,
        }
        resp = clients['c_in'].generic('POST', reverse('button_update_local'), json.dumps(post_data))
        assert resp.status_code == 200
        geneva_grp.refresh_from_db()
        assert geneva_grp not in calvin.disabled_groups.all()
