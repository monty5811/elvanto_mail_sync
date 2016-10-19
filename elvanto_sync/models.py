from django.core.urlresolvers import reverse
from django.db import models

import elvanto_sync.google as ggl


class ElvantoGroup(models.Model):
    name = models.CharField("Group Name", max_length=250)
    e_id = models.CharField("Elvanto ID", max_length=36)
    google_email = models.EmailField(
        'Google Email', max_length=254, blank=True, null=True
    )
    last_pulled = models.DateTimeField(blank=True, null=True)
    last_pushed = models.DateTimeField(blank=True, null=True)
    push_auto = models.BooleanField(
        "Auto Push?",
        default=False,
        help_text="Check this if you want changes for this group to be pushed to google periodically"
    )

    def google_emails(self):
        return ggl.fetch_emails(self.google_email)

    def check_google_group_exists(self):
        return ggl.check_mailing_list_exists(self.google_email)

    def create_google_group(self):
        ggl.create_mailing_list(self.google_email)

    def push_to_google(self):
        if self.google_email is None or not self.google_email:
            print('No email address for %s', str(self))
            return

        # TODO add check if we have a google_email!
        if not self.check_google_group_exists():
            self.create_google_group()

        ggl.push_emails_to_list(self.google_email, self.pk)

    def elvanto_emails(self):
        return list(
            self.group_members.exclude(disabled_groups__in=[self])
            .exclude(disabled_entirely=True).values_list(
                'email', flat=True
            )
        )

    def group_members_entirely_disabled(self):
        """Queryset of entirely disabled people in group"""
        return ElvantoPerson.objects.filter(disabled_entirely=True)

    def total_people_in_group(self):
        """Total number of people in group"""
        return self.group_members.all().count()

    def total_disabled_people_in_group(self):
        """Total number of people in group that have been disabled, either
        locally or globally"""
        disabled_ppl_in_group = list(self.group_members_disabled.all())
        disabled_globally = list(self.group_members_entirely_disabled())
        num_disabled = len(set(disabled_ppl_in_group + disabled_globally))
        return num_disabled

    def group_member_pks(self):
        return self.group_members.values_list('pk', flat=True)

    def __str__(self):
        return self.name

    class Meta:
        ordering = ['name']


class ElvantoPerson(models.Model):
    e_id = models.CharField("Elvanto ID", max_length=36)
    email = models.CharField("Email", max_length=250)
    first_name = models.CharField("First Name", max_length=250)
    preferred_name = models.CharField(
        "Preferred Name", max_length=250, blank=True
    )
    last_name = models.CharField("Last Name", max_length=250)
    elvanto_groups = models.ManyToManyField(
        ElvantoGroup, blank=True, related_name='group_members'
    )
    disabled_groups = models.ManyToManyField(
        ElvantoGroup, blank=True, related_name='group_members_disabled'
    )
    disabled_entirely = models.BooleanField(default=False)

    def full_name(self):
        if self.preferred_name == '':
            return "{0} {1}".format(self.first_name, self.last_name)
        else:
            return "{0} {1}".format(self.preferred_name, self.last_name)

    def __str__(self):
        return self.full_name()

    class Meta:
        ordering = ['last_name', 'first_name']
