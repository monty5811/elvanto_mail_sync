# -*- coding: utf-8 -*-
from hypothesis import given
from hypothesis.extra.fakefactory import fake_factory
from hypothesis.strategies import sets

from elvanto_sync import utils


@given(sets(fake_factory('email')),
       sets(fake_factory('email'))
       )
def test_clean_emails(email_set1, email_set2):
    utils.clean_emails(elvanto_emails=email_set1,
                       google_emails=email_set2)


def test_retry_request200():
    r = utils.retry_request('http://www.example.com/', 'get')
    assert r.status_code == 200


def test_retry_request404():
    r = utils.retry_request('http://www.github.com/monty5811/DoesNotExist', 'get')
    assert r.status_code == 404
