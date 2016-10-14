from __future__ import print_function

import json
import logging

from django.conf import settings
from django.utils import timezone
from oauth2client.service_account import ServiceAccountCredentials

from elvanto_sync import utils
from elvanto_sync.utils import retry_request

logger = logging.getLogger('elvanto_sync')


def fetch_google_token():
    creds = ServiceAccountCredentials._from_parsed_json_keyfile(
        settings.GOOGLE_KEYFILE_DICT,
        settings.SOCIAL_AUTH_GOOGLE_OAUTH2_SCOPE,
    )
    creds = creds.create_delegated(settings.G_DELEGATED_USER)
    creds.get_access_token()
    return creds.access_token


def fetch_emails(mailing_list):
    r = retry_request(
        'https://www.googleapis.com/admin/directory/v1/groups/{0}/members'.
        format(mailing_list.replace('@', '%40')),
        'get',
        params={'access_token': fetch_google_token()}
    )
    try:
        return [x['email'].lower() for x in r.json()['members']]
    except KeyError:
        return []


def check_mailing_list_exists(mailing_list):
    r = retry_request(
        'https://www.googleapis.com/admin/directory/v1/groups/{0}'.
        format(mailing_list.replace('@', '%40')),
        'get',
        params={'access_token': fetch_google_token()}
    )
    if r.status_code == 200:
        return True
    elif r.status_code == 404:
        print('{} does not exist'.format(mailing_list))
        return False


def create_mailing_list(mailing_list):
    logger.info('Creating mailing list: %s', mailing_list)
    r = retry_request(
        'https://www.googleapis.com/admin/directory/v1/groups',
        'post',
        params={'access_token': fetch_google_token()},
        data=json.dumps({
            'email': mailing_list
        }),
        headers={'Content-Type': 'application/json'}
    )
    if r.status_code == 201:
        logger.info('Created mailing list: %s', mailing_list)


def push_emails_to_list(mailing_list, group_pk):
    logger.info('Pushing to %s', mailing_list)
    from elvanto_sync.models import ElvantoGroup
    grp = ElvantoGroup.objects.get(pk=group_pk)
    if not grp.check_google_group_exists():
        grp.create_google_group()

    emails = utils.clean_emails(
        elvanto_emails=grp.elvanto_emails(), google_emails=grp.google_emails()
    )
    logger.info('Emails here: [%s]', ','.join(emails.elvanto))
    logger.info('Emails google: [%s]', ','.join(emails.google))
    # groups do not match
    here_not_on_google = set(emails.elvanto) - set(emails.google)
    logger.info('Here, not on google: [%s]', ','.join(here_not_on_google))
    on_google_not_here = set(emails.google) - set(emails.elvanto)
    logger.info('On google, not here: [%s]', ','.join(on_google_not_here))
    # TODO change to a single request
    access_token = fetch_google_token()
    for e in here_not_on_google:
        retry_request(
            'https://www.googleapis.com/admin/directory/v1/groups/{0}/members'.
            format(mailing_list.replace('@', '%40')),
            'post',
            params={'access_token': access_token},
            data=json.dumps({
                'email': e
            }),
            headers={'Content-Type': 'application/json'}
        )

    # TODO change to a single request
    for e in on_google_not_here:
        retry_request(
            'https://www.googleapis.com/admin/directory/v1/groups/{0}/members/{1}'.
            format(mailing_list.replace('@', '%40'), e.replace('@', '%40')),
            'delete',
            params={'access_token': access_token}
        )

    grp.last_pushed = timezone.now()
    grp.save()

    # check emails match now:
    new_set_of_emails = utils.clean_emails(
        elvanto_emails=grp.elvanto_emails(), google_emails=grp.google_emails()
    )
    if set(new_set_of_emails.google) != set(new_set_of_emails.elvanto):
        logger.warning(
            'Updated list of emails does not result in a match for %s',
            mailing_list
        )


def update_mailing_lists(only_auto=True):
    from elvanto_sync.models import ElvantoGroup
    groups = ElvantoGroup.objects.all()
    if only_auto:
        # if in auto mode, only push those groups that
        # are activated for auto psuhing
        groups = groups.filter(push_auto=True)

    for grp in groups:
        try:
            grp.push_to_google()
        except Exception as e:
            print('[Failed] Issue with Group: {name}'.format(name=grp.name))
            print(e)
            logger.error('Issue with group: %s', grp.name, exc_info=True)
            continue
