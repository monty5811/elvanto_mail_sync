import json
from django.http import JsonResponse
from django.shortcuts import get_object_or_404
from django.views.generic import View
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from elvanto_sync.mixins import LoginRequiredMixin
from elvanto_sync.models import ElvantoGroup, ElvantoPerson
from elvanto_sync.tasks import (bg_push_all_groups, bg_push_group, bg_refresh_elvanto_data)
from elvanto_sync.serializers import ElvantoGroupSerializer, ElvantoPersonSerializer


class IsAuthedAPIView(APIView):
    permission_classes = (IsAuthenticated, )


class UpdateGlobal(IsAuthedAPIView):
    def post(self, request, *args, **kwargs):
        data = request.data
        p_id = data.get('pk')
        disable_entirely = data.get('disable')
        assert type(disable_entirely) is bool

        prsn = get_object_or_404(ElvantoPerson, pk=p_id)
        prsn.disabled_entirely = disable_entirely
        prsn.save()

        serializer = ElvantoPersonSerializer(prsn)
        return Response(serializer.data)


class UpdateLocal(IsAuthedAPIView):
    def post(self, request, *args, **kwargs):
        data = request.data
        p_id = data.get('p_id')
        g_id = data.get('g_id')
        disable_boolean = data.get('disable')
        assert type(disable_boolean) is bool

        prsn = get_object_or_404(ElvantoPerson, pk=p_id)
        grp = get_object_or_404(ElvantoGroup, pk=g_id)
        if disable_boolean:
            grp.group_members_disabled.remove(prsn)
        else:
            grp.group_members_disabled.add(prsn)

        prsn.save()
        grp.save()

        serializer = ElvantoPersonSerializer(prsn)
        return Response(serializer.data)


class UpdateSync(IsAuthedAPIView):
    def post(self, request, *args, **kwargs):
        data = request.data
        pk = data.get('pk')
        sync_boolean = data.get('push_auto')
        assert type(sync_boolean) is bool

        grp = get_object_or_404(ElvantoGroup, pk=pk)
        grp.push_auto = sync_boolean
        grp.save()

        serializer = ElvantoGroupSerializer(grp)
        return Response(serializer.data)


class PushAll(LoginRequiredMixin, View):
    def post(self, request, *args, **kwargs):
        bg_push_all_groups.delay(only_auto=False)
        return JsonResponse({})


class PullAll(LoginRequiredMixin, View):
    def post(self, request, *args, **kwargs):
        bg_refresh_elvanto_data.delay()
        return JsonResponse({})


class PushGroup(IsAuthedAPIView):
    def post(self, request, *args, **kwargs):
        data = request.data
        g_id = data.get('g_id')
        grp = get_object_or_404(ElvantoGroup, pk=g_id)
        bg_push_group.delay(pk=grp.pk)
        return JsonResponse({'g_id': grp.pk})
