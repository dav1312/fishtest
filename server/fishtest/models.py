from pyramid.security import Allow, Everyone


class RootFactory(object):
    __acl__ = [
        (Allow, Everyone, "view"),
        (Allow, "group:approvers", "approve_run"),
        (Allow, "group:moderators", ("approve_run", "moderate")),
        (Allow, "group:administrators", ("approve_run", "moderate", "administrate"))
    ]

    def __init__(self, request):
        pass
