import json
import logging

from django.conf import settings
from django.utils import timezone
import requests

from elvanto_sync.models import ElvantoGroup, ElvantoPerson

logger = logging.getLogger('elvanto_sync')


class ElvantoApiException(Exception):
    pass


class ElvantoClient:
    def __init__(self, group=''):
        self.session = self.setup_session()

    def setup_session(self):
        s = requests.Session()
        s.auth = (settings.ELVANTO_KEY, '_')
        return s

    def make_request(self, method, end_point, json={}):
        base_url = 'https://api.elvanto.com/v1/'
        e_url = '{0}{1}.json'.format(base_url, end_point)
        resp = self.session.request(
            method,
            e_url,
            json=json,
        )

        data = resp.json()
        if data['status'] == 'ok':
            return data
        else:
            raise ElvantoApiException(data['error'])


def extract_email(e_prsn):
    custom_field = 'custom_{0}'.format(settings.EMAIL_OVERRIDE_FIELD_ID)
    try:
        if len(e_prsn[custom_field]) > 0:
            return e_prsn[custom_field]
        else:
            return e_prsn['email']
    except Exception:
        return e_prsn['email']


def _get_api(api):
    if api is None:
        api = ElvantoClient()
    return api


def pull_people(api=None):
    """
    Pull all elvanto people into db, then pull down groups to add people.
    Then iterate through them to add them to the correct groups
    """
    api = _get_api(api)
    if len(settings.EMAIL_OVERRIDE_FIELD_ID) > 0:
        custom_field = 'custom_{0}'.format(settings.EMAIL_OVERRIDE_FIELD_ID)
        custom_fields = [custom_field]
    else:
        custom_fields = []

    data = api.make_request(
        'get',
        'people/getAll',
        json={
            'fields': custom_fields,
            'page_size': settings.ELVANTO_PEOPLE_PAGE_SIZE,
        },
    )

    people = data['people']
    num_synced = people["on_this_page"]
    page = 2
    while num_synced < people["total"]:
        more_data = api.make_request(
            'get',
            'people/getAll',
            json={
                'fields': custom_fields,
                'page_size': settings.ELVANTO_PEOPLE_PAGE_SIZE,
                'page': page,
            },
        )
        for person in more_data["people"]["person"]:
            people["person"].append(person)
        num_synced += more_data["people"]["on_this_page"]
        page += 1

    for e_prsn in people['person']:
        prsn, created = ElvantoPerson.objects.get_or_create(e_id=e_prsn['id'])
        prsn.email = extract_email(e_prsn).lower()
        prsn.first_name = e_prsn['firstname'].strip()
        prsn.preferred_name = e_prsn['preferred_name'].strip()
        prsn.last_name = e_prsn['lastname'].strip()
        prsn.save()


def delete_missing_groups(data):
    """Remove groups no longer on Elvanto."""
    group_ids = [group['id'] for group in data['groups']['group']]
    missing_groups = ElvantoGroup.objects.exclude(e_id__in=group_ids)
    for grp in missing_groups:
        logger.info('Deleting %s (%s)', grp.name, grp.e_id)
        grp.group_members.clear()
        grp.delete()


def pull_groups(api=None):
    """
    Pull all elvanto groups and create entries in local db.
    """
    # Grab groups with their people
    api = _get_api(api)
    data = api.make_request(
        'get',
        'groups/getAll',
        json={'fields': ['people']},
    )
    delete_missing_groups(data)
    for e_grp in data['groups']['group']:
        # update/create group
        grp, created = ElvantoGroup.objects.get_or_create(e_id=e_grp['id'])
        grp.name = e_grp['name'].encode('utf-8', 'replace').strip()
        grp.last_pulled = timezone.now()
        # update membership
        grp.group_members.clear()
        if e_grp['people']:
            e_ids = [x['id'] for x in e_grp['people']['person']]
            people = ElvantoPerson.objects.filter(e_id__in=e_ids)
            grp.group_members.add(*people)

        grp.save()


def refresh_elvanto_data():
    """
    """
    api = ElvantoClient()
    print('Pulling Elvanto people')
    pull_people(api)
    print('Pulling Elvanto groups')
    pull_groups(api)
