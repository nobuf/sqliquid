function template_for_error(result) {
  return '<pre class="error">' + result['error'] + '</pre>';
}
function header(rows) {
  return Object.keys(rows[0]);
}
function template_for_rows(rows, limit) {
  if (!rows) {
    return 'fetching data...';
  } else if (rows['error']) {
    return template_for_error(rows);
  }
  var headers = header(rows);
  var html = '<table class="pure-table pure-table-striped rows">' +
    '<thead><tr>';
  for (var i in headers) {
    html += '<th>' + headers[i] + '</th>';
  }
  html += '</tr></thead>' +
    '<tbody>';
  for (var i in rows) {
    html += '<tr>';
    for (var j in headers) {
      html += '<td>' + rows[i][headers[j]] + '</td>';
    }
    html += '</tr>';
    if (i >= limit && limit > 0) {
      break;
    }
  }
  html += '</tbody></table>';
  return html;
}
function template(record) {
  return '<div class="record" id="record-' + record['id'] + '">' +
    '<h2>' + record['name'] + '&nbsp;' +
      '<time class="timeago created_at" datetime="' + record['created_at'] + '">' +
        record['created_at'] +
      '</time>' +
    '</h2>' +
    '<div class="query-container"><pre class="query">' + record['query'] + '</pre></div>' +
    '<div class="result">' +
      template_for_rows(JSON.parse(record['result']), 100) +
    '</div>' +
  '</div>';
}
function render(data) {
  var $records = $('#records');
  for (var i in data) {
    var id = data[i]['id'];
    var $record = $('#record-' + id)
    if ($record.length > 0) {
      $record.find('.result')
        .html(template_for_rows(JSON.parse(data[i]['result']), 100))
    } else {
      $records.prepend(template(data[i]))
    }
  }
  $('.timeago').timeago();
}
function load() {
  $.getJSON('/all')
    .done(render);
}
function bindStream() {
  var es = new EventSource('/stream');
  es.onmessage = function(e) {
    render(JSON.parse(e.data));
  };
}

(function(){
  load();
  bindStream();
})();
