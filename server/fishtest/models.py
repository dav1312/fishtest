from pyramid.security import Allow, Everyone


class RootFactory(object):
    __acl__ = [
        (Allow, Everyone, "view"),
        (Allow, "group:approvers", "approve_run"),
        (Allow, "group:moderators", "approve_run"),
        (Allow, "group:admins", "approve_run"),

        (Allow, "group:moderators", "moderate"),
        (Allow, "group:admins", "moderate"),

        (Allow, "group:admins", "administrate")
    ]

    def __init__(self, request):
        pass
