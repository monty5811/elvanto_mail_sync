from django.core.management.base import BaseCommand

from elvanto_sync.google import update_mailing_lists


class Command(BaseCommand):
    help = 'Push to all google lists.'

    def handle(self, *args, **options):
        self.stdout.write('Beginning push...')
        update_mailing_lists(only_auto=True)
        self.stdout.write('Successfully pushed')
