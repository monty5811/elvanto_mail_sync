from django.core.management.base import BaseCommand

from elvanto_sync.elvanto import refresh_elvanto_data


class Command(BaseCommand):
    help = 'Pulls info from elvanto'

    def handle(self, *args, **options):
        refresh_elvanto_data()
