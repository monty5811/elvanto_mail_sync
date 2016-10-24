from django.core.management import call_command
from django.core.management.base import BaseCommand


class Command(BaseCommand):
    help = 'Push to all google lists - requires a user to have signed in previously.'

    def handle(self, *args, **options):
        call_command('pull_from_elvanto')
        call_command('push_to_google')
        self.stdout.write('Successfully run sync')
