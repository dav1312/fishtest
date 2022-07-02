<%inherit file="base.mak"/>

<link rel="stylesheet"
      href="/css/flags.css?v=${cache_busters['css/flags.css']}"
      integrity="sha384-${cache_busters['css/flags.css']}"
      crossorigin="anonymous" />

<h2>Stockfish Testing Queue</h2>

% if page_idx == 0:
    <div class="table-responsive-sm no-scrollbar">
      <table class="table table-sm table-striped">
        <thead>
          <th>Cores</th>
          <th title="Million nodes per second">MNps</th>
          <th title="Total million nodes per second">Total MNps</th>
          <th title="Games per minute">Games/min</th>
          <th title="Hours remaining">Hours Remaining</th>
        </thead>
        <tbody>
          <td style="width: 7%">${cores}</td>
          <td style="width: 7%">${f"{nps / (cores * 1000000 + 1):.2f}"}</td>
          <td style="width: 7%">${f"{nps / (1000000 + 1):.2f}"}</td>
          <td style="width: 7%">${games_per_minute}</td>
          <td>${pending_hours}</td>
        </tbody>
      </table>
    </div>

    <h4>
      <button id="machines-button" class="btn btn-sm btn-light border">
        ${'Hide' if machines_shown else 'Show'}
      </button>
      <span>
        Workers - ${len(machines)} machines
      </span>
    </h4>

    <div id="machines"
         class="overflow-auto"
         style="${'' if machines_shown else 'display: none;'}">
      <%include file="machines_table.mak"/>
    </div>
% endif

<%include file="run_tables.mak"/>
