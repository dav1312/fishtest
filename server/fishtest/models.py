from pyramid.security import Allow, Everyone


class RootFactory(object):
    __acl__ = [
        (Allow, Everyone, "view"),
        (Allow, "group:approvers", "approve_run"),
        (Allow, "group:moderators", "approve_run"),
        (Allow, "group:administrators", "approve_run"),

        (Allow, "group:moderators", "moderate"),
        (Allow, "group:administrators", "moderate"),

        (Allow, "group:administrators", "administrate")
    ]

    def __init__(self, request):
        pass
