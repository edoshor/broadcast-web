window.bb ?= {} # create bb namespace if it doesn't already exist

window.bb.show_event = (event_id) ->
  if bb.show_event_timer? then clearInterval(bb.show_event_timer)
  bb.event_id = event_id
  bb.show_event_timer = setInterval(refresh_status, 2000)
  refresh_status()

refresh_status = () ->
  $.get("/admin/events/#{bb.event_id}/status?with_slots=true",
  (data) ->
    state = '<p>'

    if data.running
      state += '<h1>Running</h1>' + data.uptime
      $('#event_start').attr('disabled', 'disabled')
      $('#event_start').addClass('disabled')
      $('#event_stop').removeAttr('disabled')
      $('#event_stop').removeClass('disabled')
    else
      state += '<h1>Stopped</h1>'
      if (data.last_switch) then state += new Date(data.last_switch* 1000)
      $('#event_start').removeAttr('disabled')
      $('#event_start').removeClass('disabled')
      $('#event_stop').attr('disabled', 'disabled')
      $('#event_stop').addClass('disabled')

    state += '</p>'
    $('#event_status').html(state)
  , 'json'
  )

load_transcoder_slots = () ->
  $.get('/admin/transcoders/' + $('#slotModalTranscoder').val() + '/get_slots',
  (data) ->
    opts = ""
    $.each(data, (index) ->
      opts += '<option value="' + this.id + '">' + this.slot_id + ' - ' + this.scheme_name + '</option>'
    )
    $('#slotModalSlot').find('option').remove().end().append(opts)
  ,'json')

register_handlers = () ->
  $('#event_start').click ->
    $.get("/admin/events/#{bb.event_id}/action?command=start")
  $('#event_stop').click ->
    $.get("/admin/events/#{bb.event_id}/action?command=stop")
  $('#slotModal').on('show', () ->
    load_transcoder_slots())
  $('#slotModalTranscoder').change ->
    load_transcoder_slots()

$ ->
  register_handlers()

