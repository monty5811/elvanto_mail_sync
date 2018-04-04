from django.conf.urls import include, url
from django.urls import path
from django.contrib import admin
from django.views.generic import TemplateView
from rest_framework.permissions import IsAuthenticated

from elvanto_sync import views_api as va
from elvanto_sync import views_buttons as vb
from elvanto_sync.mixins import LoginRequiredMixin
from elvanto_sync.models import ElvantoGroup, ElvantoPerson
from elvanto_sync.serializers import (ElvantoGroupSerializer, ElvantoPersonSerializer)
from django.conf.urls import include, url

admin.autodiscover()


class RestrictedTemplateView(LoginRequiredMixin, TemplateView):
    pass


auth_patterns = [
    url(r'^auth/', include('allauth.urls')),
]


urls_basic = [
    path(r'admin/', admin.site.urls),
    url(r'^$', RestrictedTemplateView.as_view(template_name='elvanto_sync/index.html'), name='index'),
    url(
        r'^group/(?P<pk>[0-9]+)$',
        RestrictedTemplateView.as_view(template_name='elvanto_sync/index.html'),
        name='group'
    )
]

urls_buttons = [
    url(r'^buttons/update_global/$', vb.UpdateGlobal.as_view(), name='button_update_global'),
    url(r'^buttons/update_local/$', vb.UpdateLocal.as_view(), name='button_update_local'),
    url(r'^buttons/update_sync/$', vb.UpdateSync.as_view(), name='button_update_sync'),
    url(r'^buttons/push_all/$', vb.PushAll.as_view(), name='button_push_all'),
    url(r'^buttons/pull_all/$', vb.PullAll.as_view(), name='button_pull_all'),
    url(r'^buttons/push_group/$', vb.PushGroup.as_view(), name='button_push_group'),
]

urls_api = [
    # api
    url(
        r'^api/v1/elvanto/groups/$',
        va.ApiCollection.as_view(
            model_class=ElvantoGroup, serializer_class=ElvantoGroupSerializer, permission_classes=(IsAuthenticated, )
        ),
        name='api_groups'
    ),
    url(
        r'^api/v1/elvanto/groups/(?P<pk>[0-9]+)$',
        va.ApiMember.as_view(
            model_class=ElvantoGroup,
            serializer_class=ElvantoGroupSerializer,
            permission_classes=(IsAuthenticated, ),
        ),
        name='api_group'
    ),
    url(
        r'^api/v1/elvanto/people/$',
        va.ApiCollection.as_view(
            model_class=ElvantoPerson, serializer_class=ElvantoPersonSerializer, permission_classes=(IsAuthenticated, )
        ),
        name='api_people'
    ),
]

urlpatterns = auth_patterns + urls_buttons + urls_api + urls_basic
