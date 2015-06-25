# -*- coding: utf-8 -*-
from __future__ import print_function

import json

from django.conf import settings
from django.contrib.auth.models import User
from django.utils import timezone
from social.apps.django_app.utils import load_strategy
from social.backends.utils import load_backends

from elvanto_sync import utils
from elvanto_sync.utils import retry_request


def refresh_users_google_token(user):
    social = user.social_auth.get(provider='google-oauth2')
    load_backends(settings.AUTHENTICATION_BACKENDS)
    strategy = load_strategy()  # (backend=social.provider)
    social.refresh_token(strategy)
    return social.extra_data['access_token']


def fetch_primary_google_token():
    all_users = User.objects.all()
    for user in all_users:
        try:
            access_token = refresh_users_google_token(user)
            return access_token
        except Exception as e:
            print('Cannot refresh token for {}'.format(str(user)))
            print('\t{}'.format(e))
            continue
    return None


def fetch_emails(mailing_list):
    r = retry_request('https://www.googleapis.com/admin/directory/v1/groups/{0}/members'.format(mailing_list.replace('@', '%40')),
                      'get',
                      params={'access_token': fetch_primary_google_token()})
    try:
        return [x['email'].lower() for x in r.json()['members']]
    except KeyError:
        return []


def check_mailing_list_exists(mailing_list):
    r = retry_request('https://www.googleapis.com/admin/directory/v1/groups/{0}'.format(mailing_list.replace('@', '%40')),
                      'get',
                      params={'access_token': fetch_primary_google_token()})
    if r.status_code == 200:
        return True
    elif r.status_code == 404:
        print('{} does not exist'.format(mailing_list))
        return False


def create_mailing_list(mailing_list):
    print('creating {}'.format(mailing_list))
    r = retry_request('https://www.googleapis.com/admin/directory/v1/groups',
                      'post',
                      params={'access_token': fetch_primary_google_token()},
                      data=json.dumps({'email': mailing_list}),
                      headers={'Content-Type': 'application/json'})
    if r.status_code == 201:
        print('{} created'.format(mailing_list))


def push_emails_to_list(mailing_list, group_pk):
    from elvanto_sync.models import ElvantoGroup
    grp = ElvantoGroup.objects.get(pk=group_pk)
    if not grp.check_google_group_exists():
        grp.create_google_group()

    emails = utils.clean_emails(elvanto_emails=grp.elvanto_emails(),
                                google_emails=grp.google_emails())
    print('Here:')
    print('\t{}'.format(','.join(emails.elvanto)))
    print('Google:')
    print('\t{}'.format(','.join(emails.google)))
    # groups do not match
    here_not_on_google = set(emails.elvanto) - set(emails.google)
    print('Here, not on google:')
    print('\t{}'.format(','.join(here_not_on_google)))
    on_google_not_here = set(emails.google) - set(emails.elvanto)
    print('On google, not here:')
    print('\t{}'.format(','.join(on_google_not_here)))
    # TODO change to a single request
    access_token = fetch_primary_google_token()
    for e in here_not_on_google:
        retry_request(
            'https://www.googleapis.com/admin/directory/v1/groups/{0}/members'.format(mailing_list.replace('@', '%40')),
            'post',
            params={'access_token': access_token},
            data=json.dumps({'email': e}),
            headers={'Content-Type': 'application/json'}
        )

    # TODO change to a single request
    for e in on_google_not_here:
        retry_request(
            'https://www.googleapis.com/admin/directory/v1/groups/{0}/members/{1}'.format(mailing_list.replace('@', '%40'), e.replace('@', '%40')),
            'delete',
            params={'access_token': access_token}
        )

    grp.last_pushed = timezone.now()
    grp.save()


def update_mailing_lists(only_auto=True):
    from elvanto_sync.models import ElvantoGroup
    groups = ElvantoGroup.objects.all()
    if only_auto:
        # if in auto mode, only push those groups that
        # are activated for auto psuhing
        groups = groups.filter(push_auto=True)

    for grp in groups:
        grp.push_to_google()
