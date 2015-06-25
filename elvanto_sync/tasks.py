# -*- coding: utf-8 -*-
from __future__ import absolute_import

from celery import shared_task
from django.shortcuts import get_object_or_404

from elvanto_sync.elvanto import refresh_elvanto_data
from elvanto_sync.google import update_mailing_lists
from elvanto_sync.models import ElvantoGroup


@shared_task()
def bg_refresh_elvanto_data():
    refresh_elvanto_data()


@shared_task()
def bg_push_group(pk=None):
    grp = get_object_or_404(ElvantoGroup, pk=pk)
    grp.push_to_google()


@shared_task()
def bg_push_all_groups(only_auto=True):
    update_mailing_lists(only_auto=only_auto)
