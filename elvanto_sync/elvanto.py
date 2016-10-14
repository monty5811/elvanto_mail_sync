from __future__ import print_function

import json

from django.conf import settings
from django.utils import timezone

from elvanto_sync.models import ElvantoGroup, ElvantoPerson
from elvanto_sync.utils import retry_request


class ElvantoApiException(Exception):
    pass


def e_api(end_point, **kwargs):
    base_url = 'https://api.elvanto.com/v1/'
    e_url = '{0}{1}.json'.format(base_url, end_point)
    resp = retry_request(
        e_url, 'post', json=kwargs, auth=(settings.ELVANTO_KEY, '_')
    )
    data = json.loads(resp.text)
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


def pull_down_groups():
    """
    Pull all elvanto groups and create entries in local db.
    """
    data = e_api("groups/getAll")
    for e_grp in data['groups']['group']:
        grp, created = ElvantoGroup.objects.get_or_create(e_id=e_grp['id'])
        grp.name = e_grp['name'].encode('utf-8', 'replace').strip()
        # grp.group_members.clear()
        grp.last_pulled = timezone.now()
        grp.save()


def pull_down_people():
    """
    Pull all elvanto people into db, then pull down groups to add people.
    Then iterate through them to add them to the correct groups
    """
    if len(settings.EMAIL_OVERRIDE_FIELD_ID) > 0:
        custom_field = 'custom_{0}'.format(settings.EMAIL_OVERRIDE_FIELD_ID)
        custom_fields = [custom_field]
    else:
        custom_fields = []

    data = e_api(
        "people/getAll",
        fields=custom_fields,
        page_size=settings.ELVANTO_PEOPLE_PAGE_SIZE
    )

    people = data['people']
    num_synced = people["on_this_page"]
    page = 2
    while num_synced < people["total"]:
        more_data = e_api(
            "people/getAll",
            fields=custom_fields,
            page_size=settings.ELVANTO_PEOPLE_PAGE_SIZE,
            page=page
        )
        for person in more_data["people"]["person"]:
            people["person"].append(person)
        num_synced += more_data["people"]["on_this_page"]
        page += 1

    for e_prsn in people['person']:
        prsn, created = ElvantoPerson.objects.get_or_create(e_id=e_prsn['id'])
        prsn.email = extract_email(e_prsn)
        prsn.first_name = e_prsn['firstname'].strip()
        prsn.preferred_name = e_prsn['preferred_name'].strip()
        prsn.last_name = e_prsn['lastname'].strip()
        prsn.save()


def populate_groups():
    """
    """
    for grp in ElvantoGroup.objects.all():
        grp.group_members.clear()
        try:
            data = e_api("groups/getInfo", id=str(grp.e_id), fields=['people'])
        except Exception as e:
            print('[Failed] Issue with Group: {name}'.format(name=grp.name))
            print(e)
            continue
        if len(data['group'][0]['people']) > 0:
            for x in data['group'][0]['people']['person']:
                prsn = ElvantoPerson.objects.get(e_id=x['id'])
                prsn.elvanto_groups.add(grp)
                prsn.save()


def refresh_elvanto_data():
    """
    """
    print('Pulling Elvanto groups')
    pull_down_groups()
    print('Pulling Elvanto people')
    pull_down_people()
    print('Populating groups')
    populate_groups()
