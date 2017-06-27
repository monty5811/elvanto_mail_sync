from allauth.socialaccount.adapter import DefaultSocialAccountAdapter
from allauth.exceptions import ImmediateHttpResponse

from django.conf import settings
from django.shortcuts import render_to_response

class LockedDownGoogleAdapter(DefaultSocialAccountAdapter):

    def pre_social_login(self, request, sociallogin):
        """
        Lock down the logins so we only allow permitted domains or emails.

        If there is a domain whitelist, the email whitelist is ignored.
        """
        user = sociallogin.user
        if settings.GOOGLE_OAUTH2_WHITELISTED_DOMAINS:
            # we whitelist anyone from the domain:
            if user.email.split('@')[1] not in settings.GOOGLE_OAUTH2_WHITELISTED_DOMAINS:
                raise ImmediateHttpResponse(render_to_response('error.html'))
            return

        if settings.GOOGLE_OAUTH2_WHITELISTED_EMAILS:
            # we whitelist only specified emails:
            if user.email not in settings.GOOGLE_OAUTH2_WHITELISTED_EMAILS:
                raise ImmediateHttpResponse(render_to_response('error.html'))
