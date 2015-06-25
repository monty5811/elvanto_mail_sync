# -*- coding: utf-8 -*-
from django.shortcuts import get_object_or_404, redirect, render
from django.views.generic import View

from elvanto_sync.forms import UpdateMailListForm
from elvanto_sync.mixins import LoginRequiredMixin
from elvanto_sync.models import ElvantoGroup


class SimpleView(LoginRequiredMixin, View):
    template_name = ''

    def get(self, request, *args, **kwargs):
        context = dict()
        context['groups'] = ElvantoGroup.objects.all()
        if "group.html" in self.template_name:
            context['group'] = get_object_or_404(ElvantoGroup, pk=kwargs['pk'])
            context['form'] = UpdateMailListForm(instance=context['group'])
        return render(request, self.template_name, context)

    def post(self, request, *args, **kwargs):
        context = dict()
        if "group.html" in self.template_name:
            grp = get_object_or_404(ElvantoGroup, pk=kwargs['pk'])
            form = UpdateMailListForm(request.POST)
            if form.is_valid():
                grp.google_email = form.cleaned_data['google_email']
                grp.push_auto = form.cleaned_data['push_auto']
                grp.save()
                return redirect(grp.get_absolute_url())
            context['group'] = grp
            context['form'] = form
        return render(request, self.template_name, context)
