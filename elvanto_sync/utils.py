# -*- coding: utf-8 -*-
from collections import namedtuple

import requests


def clean_emails(elvanto_emails=(), google_emails=()):
    # exlude elvanto people with no email
    elvanto_emails = [x for x in elvanto_emails if len(x) > 0]

    emails = namedtuple('emails', ['elvanto', 'google'])
    emails.elvanto = elvanto_emails
    emails.google = google_emails
    return emails


def retry_request(url, http_method, params=None, data=None, json=None, headers=None, auth=None):
    assert http_method in ['get', 'post', 'delete', 'patch', 'put']
    MAX_TRIES = 3

    r_kwargs = {}
    if params is not None:
        r_kwargs['params'] = params
    if data is not None:
        r_kwargs['data'] = data
    if json is not None:
        r_kwargs['json'] = json
    if headers is not None:
        r_kwargs['headers'] = headers
    if auth is not None:
        r_kwargs['auth'] = auth

    r_func = getattr(requests, http_method)

    tries = 0
    while True:
        resp = r_func(url, **r_kwargs)
        if resp.status_code != 200 and tries < MAX_TRIES:
            tries += 1
            continue
        break

    return resp
