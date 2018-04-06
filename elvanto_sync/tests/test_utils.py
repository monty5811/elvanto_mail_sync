from hypothesis import given
from hypothesis.extra.fakefactory import fake_factory
from hypothesis.strategies import lists, sets

from elvanto_sync import utils


@given(sets(fake_factory('email')), sets(fake_factory('email')))
def test_clean_emails(email_set1, email_set2):
    utils.clean_emails(elvanto_emails=email_set1, google_emails=email_set2)


@given(lists(fake_factory('email')))
def test_convert_aliases_any_email(emails):
    utils.generate_all_aliases(emails)


def test_convert_aliases_removes_googlemail():
    emails = utils.generate_all_aliases([
        'test@gmail.com',
        'test2@googlemail.com',
        'test3@hotmail.com',
    ])
    assert set(emails) == set([
        'test@gmail.com',
        'test2@gmail.com',
        'test3@hotmail.com',
        'test@googlemail.com',
        'test2@googlemail.com',
    ])
