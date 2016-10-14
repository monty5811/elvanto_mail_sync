from rest_framework import serializers

from elvanto_sync.models import ElvantoGroup, ElvantoPerson


class ElvantoPersonSerializer(serializers.ModelSerializer):
    full_name = serializers.CharField()
    disabled_groups = serializers.SerializerMethodField()

    def get_disabled_groups(self, instance):
        return instance.disabled_groups.all().values_list('pk', flat=True)

    class Meta:
        model = ElvantoPerson
        fields = (
            'full_name',
            'email',
            'pk',
            'disabled_entirely',
            'disabled_groups',
        )


class ElvantoGroupSerializer(serializers.ModelSerializer):
    total_disabled_people_in_group = serializers.IntegerField(required=False)
    last_pulled = serializers.DateTimeField(
        format='%d %b %H:%M', required=False
    )
    last_pushed = serializers.DateTimeField(
        format='%d %b %H:%M', required=False
    )
    name = serializers.CharField(required=False)
    people_pks = serializers.ReadOnlyField(
       source='group_member_pks'
    )
    push_auto = serializers.BooleanField(required=False)

    class Meta:
        model = ElvantoGroup
        fields = (
            'name',
            'google_email',
            'pk',
            'push_auto',
            "last_pushed",
            "last_pulled",
            'total_disabled_people_in_group',
            'people_pks',
        )
