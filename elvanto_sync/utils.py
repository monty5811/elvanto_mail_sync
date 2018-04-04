from collections import namedtuple

import requests


def clean_emails(elvanto_emails=(), google_emails=()):
    # exlude elvanto people with no email
    elvanto_emails = [x for x in elvanto_emails if len(x) > 0]

    emails = namedtuple('emails', ['elvanto', 'google'])
    emails.elvanto = elvanto_emails
    emails.google = google_emails
    return emails


def convert_aliases(emails):
    aliases = [
        ('googlemail.com', 'gmail.com'),
    ]
    for alias in aliases:
        emails = [email.replace(alias[0], alias[1]) for email in emails]

    return emails
