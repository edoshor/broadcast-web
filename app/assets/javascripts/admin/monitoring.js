function createPlots() {
    $(".monitor-plot").each(function() {
        var element = $(this);
        var tx_id = element.data('tx-id');
        element.data('plot', $.plot(this, [], plotOptions));

        var type = element.data('type');
        if (type == 'cpu') {
            setInterval("updateCpuData('" + tx_id + "')", updateInterval);
            updateCpuData(tx_id);
        } else {
            setInterval("updateTemperatureData('" + tx_id + "')", updateInterval);
            updateTemperatureData(tx_id);
        }
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
 * Update CPU temperature data for transcoder with given id.
 * @param tx_id
 */
function updateTemperatureData(tx_id) {
  	$.ajax({
		type: 'GET',
		url: backendUrl + 'monitor/' + tx_id + '/temp?period=' + monitorPeriod(),
		dataType: 'json',
		success: function (responseData, textStatus, jqXHR) {
			var seriesData = [];
			$.each(responseData, function(i, item) {
				seriesData.push({label: 'core-' + i , data: convertTimeSeries(item)});
			});

			var plot = $('#temperature-plot-' + tx_id).data('plot');
			plot.setData(seriesData);
			plot.setupGrid();
			plot.draw();	
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
                $("#monitoring-status").text("running");
                $("#start-monitoring").addClass("disabled");
                $("#stop-monitoring").removeClass("disabled");
            } else {
                $("#monitoring-status").text("stopped");
                $("#stop-monitoring").addClass("disabled");
                $("#start-monitoring").removeClass("disabled");
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
        $("#start-monitoring").click(function() {
            $.get(backendUrl + 'monitor/start');
        });
        $("#stop-monitoring").click(function() {
            $.get(backendUrl + 'monitor/shutdown');
        });
    }
});

