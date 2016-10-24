from django.core.management.base import BaseCommand

from elvanto_sync.elvanto import refresh_elvanto_data


class Command(BaseCommand):
    help = 'Pulls info from elvanto'

    def handle(self, *args, **options):
        self.stdout.write('Beginning pull from elvanto')
        refresh_elvanto_data()
        self.stdout.write('Successfully pulled from elvanto')
