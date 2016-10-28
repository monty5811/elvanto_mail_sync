from rest_framework import serializers

from elvanto_sync.models import ElvantoGroup, ElvantoPerson


class ElvantoPersonSerializer(serializers.ModelSerializer):
    fullName = serializers.CharField(source='full_name')
    disabledEntirely = serializers.BooleanField(source='disabled_entirely')
    disabledGroups = serializers.SerializerMethodField()

    def get_disabledGroups(self, instance):
        return instance.disabled_groups.all().values_list('pk', flat=True)

    class Meta:
        model = ElvantoPerson
        fields = (
            'fullName',
            'email',
            'pk',
            'disabledEntirely',
            'disabledGroups',
        )


class ElvantoGroupSerializer(serializers.ModelSerializer):
    lastPulled = serializers.DateTimeField(
        source='last_pulled',
        format='%d %b %H:%M', required=False
    )
    lastPushed = serializers.DateTimeField(
        source='last_pushed',
        format='%d %b %H:%M', required=False
    )
    name = serializers.CharField(required=False)
    googleEmail = serializers.EmailField(source='google_email')
    peoplePks = serializers.ReadOnlyField(source='group_member_pks')
    pushAuto = serializers.BooleanField(required=False, source='push_auto')

    class Meta:
        model = ElvantoGroup
        fields = (
            'name',
            'googleEmail',
            'pk',
            'pushAuto',
            "lastPushed",
            "lastPulled",
            'peoplePks',
        )
