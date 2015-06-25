# -*- coding: utf-8 -*-
import pytest
from django.core.management import call_command

from elvanto_sync import elvanto
from elvanto_sync.models import ElvantoGroup, ElvantoPerson


@pytest.mark.slowtest
@pytest.mark.django_db
class TestElvanto():
    def test_pull_groups(self):
        elvanto.pull_down_groups()
        grp = ElvantoGroup.objects.get(e_id='7ebd2605-d3c7-11e4-95ba-068b656294b7')
        assert str(grp) == 'All'

    def test_pull_people(self):
        # TODO test emails
        elvanto.pull_down_people()
        calvin = ElvantoPerson.objects.get(e_id='f7cfa258-d3c6-11e4-95ba-068b656294b7')
        assert str(calvin) == 'John Calvin'
        assert calvin.email == 'john.calvin@geneva.com'
        chalmers = ElvantoPerson.objects.get(e_id='5a0a1cbc-d3c7-11e4-95ba-068b656294b7')
        assert str(chalmers) == 'Thomas Chalmers'
        assert chalmers.email == 'thomas.chalmers@edinburgh.com'
        knox = ElvantoPerson.objects.get(e_id='c1136264-d3c7-11e4-95ba-068b656294b7')
        assert str(knox) == 'John Knox'
        assert knox.email == ''
        owen = ElvantoPerson.objects.get(e_id='48366137-d3c7-11e4-95ba-068b656294b7')
        assert str(owen) == 'John Owen'
        assert owen.email == 'john.owen@cambridge.com'

    def test_pop_groups(self):
        elvanto.pull_down_groups()
        elvanto.pull_down_people()
        elvanto.populate_groups()
        grp_all = ElvantoGroup.objects.get(e_id='7ebd2605-d3c7-11e4-95ba-068b656294b7')
        e_emails = grp_all.elvanto_emails()
        assert 'john.calvin@geneva.com' in e_emails
        assert 'john.owen@cambridge.com' in e_emails
        assert 'thomas.chalmers@edinburgh.com' in e_emails

        assert grp_all.total_people_in_group() == 3
        assert len(grp_all.group_members_entirely_disabled()) == 0
        assert grp_all.total_disabled_people_in_group() == 0

    def test_refresh_data(self):
        elvanto.refresh_elvanto_data()

    def refresh_pull_management_command(self):
        call_command('pull_from_elvanto')
