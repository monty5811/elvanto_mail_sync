import logging
from time import sleep

from django.conf import settings
import requests
from oauth2client.service_account import ServiceAccountCredentials

logger = logging.getLogger('elvanto_sync')


class GoogleClient:
    def __init__(self, group=''):
        self.creds = self.setup_creds()
        self.session = self.setup_session()
        self.group = group

        self.base_url = 'https://www.googleapis.com/admin/directory/v1/groups/'

    def _encode_email(self, email):
        return email.replace('@', '%40')

    def encoded_group(self):
        return self._encode_email(self.group)

    def _group_url(self):
        return '{base_url}{group}'.format(
            base_url=self.base_url,
            group=self.encoded_group(),
        )

    def _members_url(self):
        return '{base_url}{group}/members'.format(
            base_url=self.base_url,
            group=self.encoded_group(),
        )

    def _member_url(self, member):
        return '{base_url}{group}/members/{member}'.format(
            base_url=self.base_url,
            group=self.encoded_group(),
            member=self._encode_email(member),
        )

    def setup_creds(self):
        creds = ServiceAccountCredentials._from_parsed_json_keyfile(
            settings.GOOGLE_KEYFILE_DICT,
            settings.SOCIAL_AUTH_GOOGLE_OAUTH2_SCOPE,
        )
        creds = creds.create_delegated(settings.G_DELEGATED_USER)
        creds.get_access_token()
        return creds

    def setup_session(self):
        s = requests.Session()
        s.params = {'access_token': self.creds.access_token}
        return s

    def refresh_session_creds(self):
        self.creds = self.setup_creds()
        self.session = self.setup_session()

    def make_request(self, method, url, data=None, attempt=1):
        resp = self.session.request(
            method,
            url,
            json=data,
        )
        try:
            resp.raise_for_status()
        except Exception:
            if resp.status_code == 401:
                self.refresh_session_creds()
                if attempt < 3:
                    self.make_request(url, method, data, attempt=attempt + 1)
            else:
                # TODO raise exception
                pass
        return resp

    def check_group_exists(self):
        r = self.make_request('get', self._group_url())
        if r.status_code == 200:
            return True
        elif r.status_code == 404:
            print('{} does not exist'.format(self.group))
            return False

    def create_group(self):
        logger.info('Creating mailing list: %s', self.group)
        r = self.make_request(
            'post', self.base_url, data={'email': self.group}
        )
        if r.status_code == 201:
            logger.info('Created mailing list: %s', self.group)

    def fetch_members(self):
        r = self.make_request('get', self._members_url())
        try:
            return [x['email'].lower() for x in r.json()['members']]
        except KeyError:
            return []

    def add_member(self, url, email, attempt=0):
        resp = self.make_request(
            'post',
            url,
            data={'email': email},
        )
        try:
            resp.raise_for_status()
        except Exception:
            if resp.status_code == 409 and attempt < 3:
                # let's wait and retry the request
                sleep(5)
                self.add_member(url, email, attempt=attempt + 1)
            else:
                logger.error(
                    'Could not add member',
                    exc_info=True,
                    extra={
                        'group': self.group,
                        'member': email,
                    }
                )

    def add_members(self, emails):
        url = self._members_url()
        for email in emails:
            self.add_member(url, email)

    def remove_members(self, emails):
        for email in emails:
            self.remove_member(email)

    def remove_member(self, email):
        url = self._member_url(email)
        resp = self.make_request(
            'delete',
            url,
        )
        try:
            resp.raise_for_status()
        except Exception:
            if resp.status_code == 404:
                logger.debug(
                    'Tried to delete member that does not exist',
                    exc_info=True,
                    extra={
                        'group': self.group,
                        'member': email,
                    }
                )
            else:
                logger.error(
                    'Could not delete member',
                    exc_info=True,
                    extra={
                        'group': self.group,
                        'member': email,
                    }
                )


def update_mailing_lists(only_auto=True):
    api = GoogleClient()
    from elvanto_sync.models import ElvantoGroup
    groups = ElvantoGroup.objects.all()
    if only_auto:
        # if in auto mode, only push those groups that
        # are activated for auto psuhing
        groups = groups.filter(push_auto=True)

    for grp in groups:
        try:
            grp.push_to_google(api=api)
        except Exception as e:
            print('[Failed] Issue with Group: {name}'.format(name=grp.name))
            print(e)
            logger.error('Issue with group: %s', grp.name, exc_info=True)
            continue
