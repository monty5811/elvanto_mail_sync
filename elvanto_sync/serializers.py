# -*- coding: utf-8 -*-
from rest_framework import serializers

from elvanto_sync.models import ElvantoGroup, ElvantoPerson


class ElvantoPersonSerializer(serializers.ModelSerializer):
    full_name = serializers.CharField()
    disabled_groups = serializers.SerializerMethodField()

    def get_disabled_groups(self, instance):
        return instance.disabled_groups.all().values_list('pk', flat=True)

    class Meta:
        model = ElvantoPerson
        fields = ('e_id', 'full_name',
                  'email', 'first_name', 'last_name',
                  'pk',
                  'disabled_entirely',
                  'disabled_groups',
                  )


class ElvantoGroupSerializer(serializers.ModelSerializer):
    url = serializers.CharField(source='get_absolute_url')
    total_disabled_people_in_group = serializers.IntegerField()
    total_people_in_group = serializers.IntegerField()
    last_pulled = serializers.DateTimeField(format='%d %b %H:%M')
    last_pushed = serializers.DateTimeField(format='%d %b %H:%M')

    class Meta:
        model = ElvantoGroup
        fields = ('e_id', 'name', 'google_email',
                  'pk',
                  "last_pushed", "last_pulled",
                  'total_disabled_people_in_group', 'total_people_in_group',
                  'url'
                  )
