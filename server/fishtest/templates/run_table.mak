<%page args="runs, pages=None, show_delete=False, header=None, count=None, toggle=None, alt=None, title=''"/>

<%namespace name="base" file="base.mak"/>

% if toggle is None:
    <script>
      document.title = '${username + " - " if username else ""}Finished Tests${title} - page ${page_idx+1} | Stockfish Testing';
    </script>
% endif

<%def name="pagination()">
  % if pages and len(pages) > 3:
      <nav>
        <ul class="pagination pagination-sm">
        % for page in pages:
            <li class="${page['state']}">
              % if page['state'] not in ['disabled', 'active']:
                  <a class="page-link" href="${page['url']}">${page['idx']}</a>
              % else:
                  <a class="page-link">${page['idx']}</a>
              % endif
            </li>
        % endfor
        </ul>
      </nav>
  % endif
</%def>

<%
  from fishtest.util import get_cookie
  if toggle:
    cookie_name = toggle+"-state"
%>

% if toggle:
<script>
    function toggle_${toggle}() {
        var button = $("#${toggle}-button");
        var div = $("#${toggle}");
        var active = button.text().trim() === 'Hide';
        button.text(active ? 'Show' : 'Hide');
        div.slideToggle(150);
        $.cookie('${cookie_name}', button.text().trim(), {expires : 3650});
    }
</script>
% endif


<h4>
% if toggle:
    <button id="${toggle}-button" class="btn btn-sm btn-light border" onclick="toggle_${toggle}()">
    ${'Hide' if get_cookie(request, cookie_name)=='Hide' else 'Show'}
    </button>
% endif
% if header is not None and count is not None:
  ${header} - ${count} tests
% elif header is not None:
  ${header}
% elif count is not None:
  ${count} tests
% endif
</h4>

<div
   id="${toggle}"
% if toggle:
   style="${'' if get_cookie(request, cookie_name)=='Hide' else 'display: none;'}"
% endif
>

  ${pagination()}

  <div class="container-fluid rows-striped g-0">
    % for run in runs:
        <div class="row g-1 mb-2">
          <div class="col-lg-3">
            <div class="row g-1">
              % if show_delete:
                  <div class="col">
                    <button type="button" class="btn btn-sm btn-danger" data-bs-toggle="modal" data-bs-target="#confirm-modal-${run['_id']}">
                      <i class="fas fa-trash-alt"></i>
                    </button>
                    <div class="modal fade" id="confirm-modal-${run['_id']}" tabindex="-1" aria-hidden="true">
                      <div class="modal-dialog">
                        <div class="modal-content">
                          <div class="modal-header">
                            <h5 class="modal-title">Confirm that you want to delete ${run['args']['new_tag'][:23]}</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                          </div>
                          <div class="modal-footer">
                            <form action="/tests/delete" class="mb-0" method="POST">
                              <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                              <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}" />
                              <input type="hidden" name="run-id" value="${run['_id']}">
                              <button type="submit" class="btn btn-outline-danger">Confirm</button>
                            </form>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>

              % endif

              <div class="col">${run['start_time'].strftime("%y-%m-%d")}</div>
              <div class="col"><a class="text-break" href="/tests/user/${run['args'].get('username', '')}" title="${run['args'].get('username', '')}">${run['args'].get('username', '')[:3]}</a></div>
              <div class="col"><a class="text-break" href="/tests/view/${run['_id']}">${run['args']['new_tag'][:23]}</a></div>
              <div class="col"><a class="text-break" href="${h.diff_url(run)}" target="_blank" rel="noopener">diff</a></div>
            </div>
          </div>

          <div class="col-sm-9 col-lg-4 order-last order-lg-0"><%include file="elo_results.mak" args="run=run" /></div>

          <div class="col-sm-3 col-lg-1">
            % if 'sprt' in run['args']:
                <a class="text-break" href="/tests/live_elo/${str(run['_id'])}" target="_blank">sprt</a>
            % else:
              ${run['args']['num_games']}
            % endif
            @ ${run['args']['tc']} th ${str(run['args'].get('threads',1))}
            <br>
            ${('cores: '+str(run['cores'])) if not run['finished'] and 'cores' in run else ''}
          </div>

          <div class="col order-last order-lg-0">${run['args'].get('info', '')}</div>
        </div>
    % endfor
    % if alt and count == 0:
      <div class="col-12">
        <div class="alert alert-info" role="alert">${alt}</div>
      </div>
    % endif
  </div>

  ${pagination()}
</div>
