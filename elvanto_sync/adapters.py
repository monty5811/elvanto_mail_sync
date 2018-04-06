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
        if settings.GOOGLE_OAUTH2_WHITELISTED_DOMAINS is not None:
            # we whitelist anyone from the domain:
            if user.email.split('@')[1] not in settings.GOOGLE_OAUTH2_WHITELISTED_DOMAINS:
                raise ImmediateHttpResponse(render_to_response('error.html'))
            # skip checking white listed emails:
            return

        if settings.GOOGLE_OAUTH2_WHITELISTED_EMAILS is not None:
            # we whitelist only specified emails:
            if user.email  in settings.GOOGLE_OAUTH2_WHITELISTED_EMAILS:
                # user is good
                return
            else:
                raise ImmediateHttpResponse(render_to_response('error.html'))

        # no whitelists found, do not permit any login
        raise ImmediateHttpResponse(render_to_response('error.html'))
