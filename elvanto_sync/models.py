import logging
from django.db import models
from django.urls import reverse
from django.utils import timezone

from elvanto_sync.google import GoogleClient
from elvanto_sync import utils

logger = logging.getLogger('elvanto_sync')


class ElvantoGroup(models.Model):
    name = models.CharField("Group Name", max_length=250)
    e_id = models.CharField("Elvanto ID", max_length=36)
    google_email = models.EmailField('Google Email', max_length=254, blank=True, null=True)
    last_pulled = models.DateTimeField(blank=True, null=True)
    last_pushed = models.DateTimeField(blank=True, null=True)
    push_auto = models.BooleanField(
        "Auto Push?",
        default=False,
        help_text="Check this if you want changes for this group to be pushed to google periodically"
    )

    def push_to_google(self, api=None):
        """Push to google.

        Reuse api if provided.
        """
        # Check if we have an email to sync to:
        if self.google_email is None or not self.google_email:
            logger.info(f'No email address for {str(self)}')
            return
        logger.info(f'Pushing to {self.google_email}')

        # Reuse api session, and update obj with email address:
        if api is None:
            api = GoogleClient(group=self.google_email)

        api.group = self.google_email

        # Sync:
        if not api.check_group_exists():
            api.create_group()

        emails = utils.clean_emails(elvanto_emails=self.elvanto_emails(), google_emails=api.fetch_members())
        logger.debug(f'Emails here: [{",".join(emails.elvanto)}]')
        logger.debug(f'Emails google: [{",".join(emails.google)}]')
        here_not_on_google = set(emails.elvanto) - set(emails.google)
        logger.debug(f'Here, not on google: [{",".join(here_not_on_google)}]')
        on_google_not_here = set(emails.google) - set(emails.elvanto)
        logger.debug(f'On google, not here: [{",".join(on_google_not_here)}]')

        # update the group, we must call remove first, otherwise we may add
        # a member and then remove them due to domain aliases
        api.remove_members(on_google_not_here)
        api.add_members(here_not_on_google)

        self.last_pushed = timezone.now()
        self.save()

        # check emails match now:
        new_emails = utils.clean_emails(elvanto_emails=self.elvanto_emails(), google_emails=api.fetch_members())
        new_emails.google = utils.convert_aliases(new_emails.google)  # process aliases
        new_emails.elvanto = utils.convert_aliases(new_emails.elvanto)  # process aliases
        self._check_emails_match(new_emails)

    def _check_emails_match(self, emails):
        emails.google = utils.convert_aliases(emails.google)
        emails.elvanto = utils.convert_aliases(emails.elvanto)

        here_not_on_google = set(emails.elvanto) - set(emails.google)
        on_google_not_here = set(emails.google) - set(emails.elvanto)
        if (len(here_not_on_google) + len(on_google_not_here)) > 0:
            logger.warning(
                'Updated list of emails does not result in a match for {}. Here, not on google: {} On google, not here: {}'.format(
                    self.google_email,
                    ','.join(sorted(here_not_on_google)),
                    ','.join(sorted(on_google_not_here)),
                )
            )

    def elvanto_emails(self):
        return list(
            self.group_members.exclude(disabled_groups__in=[self])
            .exclude(disabled_entirely=True).values_list('email', flat=True)
        )

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
    preferred_name = models.CharField("Preferred Name", max_length=250, blank=True)
    last_name = models.CharField("Last Name", max_length=250)
    elvanto_groups = models.ManyToManyField(ElvantoGroup, blank=True, related_name='group_members')
    disabled_groups = models.ManyToManyField(ElvantoGroup, blank=True, related_name='group_members_disabled')
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
