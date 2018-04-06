from collections import namedtuple

import requests


def clean_emails(elvanto_emails=(), google_emails=()):
    # exlude elvanto people with no email
    elvanto_emails = [x for x in elvanto_emails if len(x) > 0]

    emails = namedtuple('emails', ['elvanto', 'google'])
    emails.elvanto = elvanto_emails
    emails.google = google_emails
    return emails


aliases = [
    ('googlemail.com', 'gmail.com'),
    ]


def generate_all_aliases(emails):
    for alias in aliases:
        tmp_emails_1 = [email.replace(alias[0], alias[1]) for email in emails]
        tmp_emails_2 = [email.replace(alias[1], alias[0]) for email in emails]

    return list(set(emails) | set(tmp_emails_1) | set(tmp_emails_2))


def compare_emails(a, b):
    # naive that doesn't handle aliases:
    # return set(a) - set(b)
    output = set()
    for email in a:
        if a in b:
            # if the email is in b, we can go to next
            continue
        # get all the aliases
        aliased_tmp = generate_all_aliases([email])
        # check if any aliases are in b:
        if any(x in b for x in aliased_tmp):
            continue

        # neither email or any aliases are in b, keep it
        output.add(email)

    return output
