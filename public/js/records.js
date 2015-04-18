function template_for_error(result) {
  return '<div class="error">' + result['error'] + '</div>';
}
function header(rows) {
  return Object.keys(rows[0]);
}
function template_for_rows(rows, limit) {
  if (rows['error']) {
    return template_for_error(rows);
  }
  var headers = header(rows);
  var html = '<table class="rows">' +
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
function template(records) {
  var html = '';
  for (var i in records) {
    html += '<div class="record">' +
      '<h2>' + records[i]['name'] + '</h2>' +
      '<div class="created_at">' + records[i]['created_at'] + '</div>' +
      '<pre class="query">' + records[i]['query'] + '</pre>' +
      '<div class="result">' +
        template_for_rows(JSON.parse(records[i]['result']), 100) +
      '</div>' +
    '</div>';
  }
  return html;
}
function render(data) {
  $('#records').prepend(template(data));
}
function load() {
  $.getJSON('/all')
    .done(render);
}

(function(){
  load();
})();
