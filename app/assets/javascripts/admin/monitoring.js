function createPlots() {
    $(".monitor-plot").each(function() {
        var element = $(this);
        var tx_id = element.data('tx-id');
        element.data('plot', $.plot(this, [], plotOptions));
        setInterval("updateCpuData('" + tx_id + "')", updateInterval);
        setInterval("updateSignalStatus('" + tx_id + "')", updateInterval);
        updateCpuData(tx_id);
        updateSignalStatus(tx_id);
    });
}

/**
 * Update CPU load data for transcoder with given id.
 * @param tx_id
 */
function updateCpuData(tx_id) {
  	$.ajax({
		type: 'GET',
		url: backendUrl + 'monitor/' + tx_id + '/cpu?period=' + monitorPeriod(),
		dataType: 'json',
		success: function (responseData, textStatus, jqXHR) {
			var plot = $('#cpu-plot-' + tx_id).data('plot');
			plot.setData([ convertTimeSeries(responseData) ]);
			plot.setupGrid();
			plot.draw();	
		}
	});
}

/**
 * Update CPU load data for transcoder with given id.
 * @param tx_id
 */
function updateSignalStatus(tx_id) {
    $.ajax({
        type: 'GET',
        url: backendUrl + 'transcoders/' + tx_id + '/slots/status',
        dataType: 'json',
        success: function (responseData, textStatus, jqXHR) {
            var row = '<tr>';
            var data = responseData.sort(function(a,b) {
                if (a.slot_id > b.slot_id) {
                    return 1;
                } else {
                    return -1;
                }
            });
            $.each(data, function(ind, item) {
                row += '<td class="';
                if (item.running) {
                  if (item.signal > 0) {
                      row += 'has-signal';
                  } else {
                      row += 'no-signal';
                  }
                }
                row += '"> ' + item.slot_id + '</td>';
            });
            row += '</tr>';
            $('#signal-status-' + tx_id).empty().append(row);
        }
    });
}

function updateStatus() {
    $.ajax({
        type: 'GET',
        url: backendUrl + 'monitor/status',
        dataType: 'json',
        success: function (responseData, textStatus, jqXHR) {
            if (responseData.status) {
                $("#monitoring-status")
                    .removeClass("btn-success").addClass("btn-danger")
                    .html('<i class="icon-align-left icon-stop"></i>  Stop Monitoring');
            } else {
                $("#monitoring-status")
                    .removeClass("btn-danger").addClass("btn-success")
                    .html('<i class="icon-align-left icon-play"></i>  Start Monitoring');
            }
        }
    });
}

/**
 * Get monitor period the user selected.
 * @returns remote query api period parameter.
 */
function monitorPeriod() {
	return	$("#monitor-period").val();
}

/**
 * Convert the time series to JavaScript timestamps.
 *
 * The remote api return UNIX timestamps, i.e. seconds since the epoch.
 * We need to multiply by 1000 to get it in milliseconds.
 *
 * The method modifies its input in place.
 * @param series Time series to be converted
 */
function convertTimeSeries(series) {
	for (var i = 0; i < series.length; ++i) {
        series[i][0] *= 1000;
	}
    return series;
}

$(document).ready(function() {
    if (typeof updateInterval != 'undefined') {
        createPlots();
        updateStatus();
        setInterval("updateStatus()", updateInterval);

        $("#monitoring-status").click(function() {
            var action = 'start';
            if ($("#monitoring-status").text() == 'Stop Monitoring') {
                action = 'shutdown';
            }
            $.get(backendUrl + 'monitor/'+ action);
        });
    }
});

