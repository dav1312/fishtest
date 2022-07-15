<%inherit file="base.mak"/>

<%
  user_is_blocked = user['blocked'] if 'blocked' in user else False
  user_is_approver = True if 'group:approvers' in user['groups'] else False
  user_is_moderator = True if 'group:moderators' in user['groups'] else False
  user_is_administrator = True if 'group:administrators' in user['groups'] else False
  show_submit = False
%>

<script>
  document.title = 'User Administration | Stockfish Testing';
</script>

<div class="col-limited-size">
  <header class="text-md-center py-2">
    <h2>User Administration</h2>
    <div class="alert alert-info">
      <h4 class="alert-heading">
        <a href="/tests/user/${user['username']}" class="alert-link col-6 text-break">${user['username']}</a>
      </h4>
      <div class="row g-1">
        % if not profile:
          <div class="col-6 text-md-end">Email:</div>
          <div class="col-6 text-start text-break"><a href="mailto:${user['email']}?Subject=Fishtest%20Account" class="alert-link">${user['email']}</a></div>
        % endif
        <div class="col-6 text-md-end">Registered:</div>
        <div class="col-6 text-start text-break">${user['registration_time'] if 'registration_time' in user else 'Unknown'}</div>
        <div class="col-6 text-md-end">Machine Limit:</div>
        <div class="col-6 text-start text-break">${limit}</div>
        <div class="col-6 text-md-end">CPU-Hours:</div>
        <div class="col-6 text-start text-break">${hours}</div>
      </div>
    </div>
  </header>

  <form action="${request.url}" method="POST">
    ## admins can change the password of other users, except other admins
    % if profile or (admin and not user_is_administrator):
      <%
        show_submit = True
      %>
      <div class="form-floating mb-3">
        <input
          type="email"
          class="form-control mb-3"
          id="email"
          name="email"
          value="${user['email']}"
          placeholder="Email"
          required="required"
        />
        <label for="email" class="d-flex align-items-end">Email</label>
      </div>

      <div class="form-floating mb-3">
        <input
          type="password"
          class="form-control mb-3"
          id="password"
          name="password"
          placeholder="Password"
          pattern=".{8,}"
          title="Eight or more characters: a password too simple or trivial to guess will be rejected"
          ${'required="required"' if profile else ''}
        />
        <label for="password" class="d-flex align-items-end">New Password</label>
      </div>

      <div class="form-floating mb-3">
        <input
          type="password"
          class="form-control mb-3"
          id="password2"
          name="password2"
          placeholder="Repeat Password"
          ${'required="required"' if profile else ''}
        />
        <label for="password2" class="d-flex align-items-end">Repeat Password</label>
      </div>
    % endif

    ## can't autoblock and have to be a mod
    % if not profile and moderator:
      ## admins can block moderators but not other admins
      ## moderators can't block other mods or admins
      % if (admin and (user_is_moderator and not user_is_administrator)) or (moderator and (not user_is_moderator and not user_is_administrator)):
        <%
          show_submit = True
        %>
        <div class="mb-3 form-check">
          <label for="blocked">Blocked</label>
          <input
            type="checkbox"
            class="form-check-input"
            id="blocked"
            name="blocked"
            value="True"
            ${'checked' if user_is_blocked else ''}
          />
        </div>
      % endif
    % endif

    % if not profile and admin and not user_is_administrator:
      <%
        show_submit = True
      %>
      <div class="mb-3">
        <label class="form-label" for="rol">Rol:</label>
        <select class="form-select" id="rol">
          <option value="norole" ${'selected' if not user_is_approver and not user_is_moderator else ''}>Regular user</option>
          <option value="approver" ${'selected' if user_is_approver else ''}>Approver</option>
          <option value="moderator" ${'selected' if user_is_moderator else ''}>Moderator</option>
        </select>
      </div>
    % endif

    % if show_submit:
      <button type="submit" class="btn btn-primary w-100">Submit</button>
      <input type="hidden" name="user" value="${user['username']}" />
    % endif
  </form>
</div>
