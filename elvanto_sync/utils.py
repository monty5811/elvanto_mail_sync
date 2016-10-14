from collections import namedtuple

import requests


def clean_emails(elvanto_emails=(), google_emails=()):
    # exlude elvanto people with no email
    elvanto_emails = [x for x in elvanto_emails if len(x) > 0]

    emails = namedtuple('emails', ['elvanto', 'google'])
    emails.elvanto = elvanto_emails
    emails.google = google_emails
    return emails


def retry_request(url, http_method, *args, **kwargs):
    assert http_method in ['get', 'post', 'delete', 'patch', 'put']
    MAX_TRIES = 3
    r_func = getattr(requests, http_method)
    tries = 0
    while True:
        resp = r_func(url, *args, **kwargs)
        if resp.status_code != 200 and tries < MAX_TRIES:
            tries += 1
            continue
        break

    return resp
