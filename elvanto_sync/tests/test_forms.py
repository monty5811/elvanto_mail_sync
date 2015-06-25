# -*- coding: utf-8 -*-
from elvanto_sync.forms import UpdateMailListForm


def test_update_mail_list():
    form_data = {
        'google_email': 'test@example.com',
        'push_auto': False
    }
    form = UpdateMailListForm(data=form_data)
    assert form.is_valid()
