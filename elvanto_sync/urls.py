# -*- coding: utf-8 -*-
from django.conf.urls import include, url
from django.contrib import admin
from rest_framework.permissions import IsAuthenticated

from elvanto_sync import views_api as va
from elvanto_sync import views_buttons as vb
from elvanto_sync import views
from elvanto_sync.models import ElvantoGroup, ElvantoPerson
from elvanto_sync.serializers import (ElvantoGroupSerializer,
                                      ElvantoPersonSerializer)

admin.autodiscover()

urls_basic = [
    url(r'^admin/', include(admin.site.urls)),
    url('', include('social.apps.django_app.urls', namespace='social')),
    url(r'^$', views.SimpleView.as_view(template_name='elvanto_sync/index.html'), name='index'),
    url(r'^group/(?P<pk>\d+)/$', views.SimpleView.as_view(template_name='elvanto_sync/group.html'), name='group'),
]
urls_buttons = [
    url(r'^buttons/update_global/$', vb.UpdateGlobal.as_view(), name='button_update_global'),
    url(r'^buttons/update_local/$', vb.UpdateLocal.as_view(), name='button_update_local'),
    url(r'^buttons/push_all/$', vb.PushAll.as_view(), name='button_push_all'),
    url(r'^buttons/pull_all/$', vb.PullAll.as_view(), name='button_pull_all'),
    url(r'^buttons/push_group/$', vb.PushGroup.as_view(), name='button_push_group'),
]
urls_api = [
    # api
    url(r'^api/v1/elvanto/groups/$',
        va.ApiCollection.as_view(model_class=ElvantoGroup,
                                 serializer_class=ElvantoGroupSerializer,
                                 permission_classes=(IsAuthenticated,)
                                 ),
        name='api_groups'),
    url(r'^api/v1/elvanto/groups/(?P<pk>[0-9]+)$',
        va.ApiMember.as_view(model_class=ElvantoGroup,
                             serializer_class=ElvantoGroupSerializer,
                             permission_classes=(IsAuthenticated, ),
                             ),
        name='api_group'),
    url(r'^api/v1/persons/$',
        va.ApiCollection.as_view(model_class=ElvantoPerson,
                                 serializer_class=ElvantoPersonSerializer,
                                 permission_classes=(IsAuthenticated,)
                                 ),
        name='api_persons'),
    url(r'^api/v1/persons/(?P<pk>[0-9]+)$',
        va.ApiMember.as_view(model_class=ElvantoPerson,
                             serializer_class=ElvantoPersonSerializer,
                             permission_classes=(IsAuthenticated, ),
                             ),
        name='api_person'),
    url(r'^api/v1/elvanto/persons/group/(?P<pk>[0-9]+)/$',
        va.ApiCollectionGroupPeople.as_view(permission_classes=(IsAuthenticated,),
                                            ),
        name='api_group_people'),
]

urlpatterns = urls_basic + urls_buttons + urls_api
