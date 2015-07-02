# -*- coding: utf-8 -*-
import json

from django.http import HttpResponse
from django.shortcuts import get_object_or_404
from django.views.generic import View

from elvanto_sync.mixins import LoginRequiredMixin
from elvanto_sync.models import ElvantoGroup, ElvantoPerson
from elvanto_sync.tasks import (bg_push_all_groups, bg_push_group,
                                bg_refresh_elvanto_data)


class UpdateGlobal(LoginRequiredMixin, View):

    def post(self, request, *args, **kwargs):
        p_id = json.loads(request.POST.get('p_id'))
        disable_entirely = json.loads(request.POST.get('disable'))
        assert type(disable_entirely) is bool

        prsn = get_object_or_404(ElvantoPerson, pk=p_id)
        prsn.disabled_entirely = disable_entirely

        prsn.save()
        json_resp = {"pk": prsn.pk}
        return HttpResponse(
            json.dumps(json_resp),
            content_type="application/json"
        )


class UpdateLocal(LoginRequiredMixin, View):

    def post(self, request, *args, **kwargs):
        p_id = json.loads(request.POST.get('p_id'))
        g_id = json.loads(request.POST.get('g_id'))
        disable_boolean = json.loads(request.POST.get('disable'))
        assert type(disable_boolean) is bool

        prsn = get_object_or_404(ElvantoPerson, pk=p_id)
        grp = get_object_or_404(ElvantoGroup, pk=g_id)
        if disable_boolean:
            grp.group_members_disabled.remove(prsn)
        else:
            grp.group_members_disabled.add(prsn)

        prsn.save()
        grp.save()
        json_resp = {"p_pk": prsn.pk, "g_pk": grp.pk}
        return HttpResponse(
            json.dumps(json_resp),
            content_type="application/json"
        )


class PushAll(LoginRequiredMixin, View):

    def post(self, request, *args, **kwargs):
        bg_push_all_groups.delay(only_auto=False)
        json_resp = {}
        return HttpResponse(
            json.dumps(json_resp),
            content_type="application/json"
        )


class PullAll(LoginRequiredMixin, View):

    def post(self, request, *args, **kwargs):
        bg_refresh_elvanto_data.delay()
        json_resp = {}
        return HttpResponse(
            json.dumps(json_resp),
            content_type="application/json"
        )


class PushGroup(LoginRequiredMixin, View):

    def post(self, request, *args, **kwargs):
        g_id = json.loads(request.POST.get('g_id'))
        grp = get_object_or_404(ElvantoGroup, pk=g_id)
        bg_push_group.delay(pk=grp.pk)
        json_resp = {'g_id': grp.pk}
        return HttpResponse(
            json.dumps(json_resp),
            content_type="application/json"
        )
