window.bb ?= {} # create bb namespace if it doesn't already exist

window.bb.show_transcoder = (tx_id) ->
  if bb.show_transcoder_timer? then clearInterval(bb.show_transcoder_timer)
  bb.tx_id = tx_id
  bb.show_transcoder_timer = setInterval(refresh_status, 2000)

window.bb.call_slot_action = (s_id, action) ->
  $.get("/admin/transcoders/#{bb.tx_id}/#{action}_slot?slot_id=#{s_id}");
  false

refresh_status = () ->
  $.get("/admin/transcoders/#{bb.tx_id}/slots_status",
  (data) ->
    $.each(data, (i, status) ->
      statusHtml = 'Stopped';
      actionLink = '<button class=\"btn btn-success\"' +
      'onclick=\"javascript:bb.call_slot_action(' + status.id + ',\'start\');\">' +
      '<i class=\"icon-align-left icon-play\"></i> Start</button>'

      if status.running
        statusHtml = "Running, uptime: #{ status.uptime }"
        actionLink = '<button class=\"btn btn-danger\"' +
        'onclick=\"javascript:bb.call_slot_action(' + status.id + ',\'stop\');\">' +
        '<i class=\"icon-align-left icon-stop\"></i> Stop</button>'

      $('#slot_state_' + status.slot_id).text(statusHtml)
      $('#slot_action_' + status.slot_id).html(actionLink)
    )
  , 'json'
  )

