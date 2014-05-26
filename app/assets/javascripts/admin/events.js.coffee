window.bb ?= {}

bb.show_event = (event_id) ->
  if bb.show_event_timer? then clearInterval(bb.show_event_timer)
  bb.event_id = event_id
  bb.show_event_timer = setInterval(refresh_status, 2000)
  refresh_status()

refresh_status = () ->
  $.get("#{bb.event_id}/status?with_slots=true",
  (data) ->
    state = '<p>'
    switch data.state
      when "off"
        state += '<h1>Off</h1>'
        if (data.last_switch) then state += new Date(data.last_switch* 1000)
        $('#event_on').attr('disabled', 'disabled')
        $('#event_on').addClass('disabled')
      when "ready"
        state += '<h1>Ready</h1>'
        if (data.last_switch) then state += new Date(data.last_switch* 1000)
        $('#event_on').removeAttr('disabled')
        $('#event_on').removeClass('disabled')
      when "on"
        state += '<h1>On</h1>' + data.uptime
      else
        $('#event_ready').removeAttr('disabled')
        $('#event_ready').removeClass('disabled')

    state += '</p>'
    $('#event_status').html(state)
  , 'json'
  )

load_transcoder_slots = () ->
  $.get('../transcoders/' + $('#slotModalTranscoder').val() + '/get_slots',
  (data) ->
    $('#slots_message').hide()
    opts = ""
    $.each(data, (index) ->
      opts += '<option value="' + this.id + '">' + this.slot_id + ' - ' + this.scheme_name + '</option>'
    )
    $('#slotModalSlot').find('option').remove().end().append(opts)
  ,'json'
  ).fail (jqHXR, textStatus) ->
    error = JSON.parse(jqHXR.responseText);
    $('#slots_message').text(error['errors']).show()

register_handlers = () ->
  $('#event_on').click ->
    $.get("#{bb.event_id}/action?command=on")
  $('#event_off').click ->
    $.get("#{bb.event_id}/action?command=off")
  $('#event_ready').click ->
    $.get("#{bb.event_id}/action?command=ready")
  $('#slotModal').on('show', () ->
    load_transcoder_slots())
  $('#slotModalTranscoder').change ->
    load_transcoder_slots()

$ ->
  register_handlers()