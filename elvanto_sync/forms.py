# -*- coding: utf-8 -*-
from django import forms

from elvanto_sync.models import ElvantoGroup


class UpdateMailListForm(forms.ModelForm):

    class Meta:
        model = ElvantoGroup
        fields = ['google_email', 'push_auto']
