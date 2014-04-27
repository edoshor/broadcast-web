window.bb ?= {}

bb.show_transcoder = (tx_id) ->
  if bb.show_transcoder_timer? then clearInterval(bb.show_transcoder_timer)
  bb.tx_id = tx_id
  bb.show_transcoder_timer = setInterval(refresh_status, 2000)
  refresh_status()

bb.call_slot_action = (s_id, action) ->
  $.get("#{bb.tx_id}/#{action}_slot?slot_id=#{s_id}");
  false

refresh_status = () ->
  $.get("#{bb.tx_id}/slots_status",
  (data) ->
    $('#slots_message').hide()
    $.each(data, (i, status) ->
      statusHtml = 'Stopped';
      actionLink = '<button class=\"btn btn-success\"' +
      'onclick=\"javascript:bb.call_slot_action(' + status.id + ',\'start\');\">' +
      '<i class=\"icon-align-left icon-play\"></i> Start</button>'

      if status.running
        if status.signal > 0
          statusHtml = '<span class="label label-success">Good Signal</span>'
        else
          statusHtml = '<span class="label label-important">No Signal</span>'
        statusHtml += " #{ status.uptime } "

        actionLink = '<button class=\"btn btn-danger\"' +
        'onclick=\"javascript:bb.call_slot_action(' + status.id + ',\'stop\');\">' +
        '<i class=\"icon-align-left icon-stop\"></i> Stop</button>'

      $('#slot_state_' + status.slot_id).html(statusHtml)
      $('#slot_action_' + status.slot_id).html(actionLink)
    )
  , 'json'
  ).fail (jqHXR, textStatus) ->
    error = JSON.parse(jqHXR.responseText);
    $('#slots_message').text(error['errors']).show()

