# -*- coding: utf-8 -*-
from __future__ import print_function

import ElvantoAPI
from django.conf import settings
from django.utils import timezone

from elvanto_sync.models import ElvantoGroup, ElvantoPerson


def elvanto():
    return ElvantoAPI.Connection(APIKey=settings.ELVANTO_KEY)


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
    e_api = elvanto()
    data = e_api._Post("groups/getAll")
    if data['status'] == 'ok':
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
    e_api = elvanto()
    if len(settings.EMAIL_OVERRIDE_FIELD_ID) > 0:
        custom_field = 'custom_{0}'.format(settings.EMAIL_OVERRIDE_FIELD_ID)
        custom_fields = [custom_field]
    else:
        custom_fields = []

    resp = e_api._Post("people/getAll",
                       fields=custom_fields,
                       page_size=settings.ELVANTO_PEOPLE_PAGE_SIZE)
    if resp['status'] != 'ok':
        return

    data = resp['people']
    num_synced = data["on_this_page"]
    page = 2
    while num_synced < data["total"]:
        more_people = e_api._Post("people/getAll",
                                  fields=custom_fields,
                                  page_size=settings.ELVANTO_PEOPLE_PAGE_SIZE,
                                  page=page)
        for person in more_people["people"]["person"]:
            data["person"].append(person)
        num_synced += more_people["people"]["on_this_page"]
        page += 1
    for e_prsn in data['person']:
        prsn, created = ElvantoPerson.objects.get_or_create(e_id=e_prsn['id'])
        prsn.email = extract_email(e_prsn)
        prsn.first_name = e_prsn['firstname'].strip()
        prsn.preferred_name = e_prsn['preferred_name'].strip()
        prsn.last_name = e_prsn['lastname'].strip()
        prsn.save()


def populate_groups():
    """
    """
    e_api = elvanto()
    for grp in ElvantoGroup.objects.all():
        grp.group_members.clear()
        data = e_api._Post("groups/getInfo", id=grp.e_id, fields=['people'])
        if data['status'] == 'ok' and len(data['group'][0]['people']) > 0:
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
