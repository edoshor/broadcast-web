window.bb ?= {} # create bb namespace if it doesn't already exist

window.bb.remove_track = (row_id) ->
  $('#tracksTable').data('tracks').splice(row_id, 1)
  bb.redraw_tracks_table()

window.bb.humanize_channels = (channels) ->
  if channels == '0' then 'video' else 'audio'

window.bb.humanize_profile = (profile) ->
  switch profile
    when '1' then '320x240, 120Kbit'
    when '2' then '360x270, 200Kbit'
    when '3' then '640x480, 400Kbit'
    when '4' then '720x540, 600Kbit'
    when '101' then 'AAC, 32Kbit, mono'
    when '102' then 'AAC, 48Kbit, mono'
    when '103' then 'AAC, 96Kbit, stereo'
    else profile


window.bb.redraw_tracks_table = () ->
  table = $('#tracksTable>tbody')
  table.empty()
  tracks = $('#tracksTable').data('tracks')
  for track, i in tracks
    row = "<tr>"
    row += "<td> #{ bb.humanize_channels(track.num_channels) } </td>"
    row += "<td> #{ bb.humanize_profile(track.profile_number) } </td>"
    row += "<td> #{ track.gain } </td>"
    row += "<td><a href='#' onclick='javascript:bb.remove_track(#{ i }); false;'>delete</a></td>"
    row += "</tr>"
    table.append(row)

register_handlers = () ->
  $('#tracksTable').data('tracks', [])

  $('#trackModalChannels').change ->
    if $(this).val() == '0'
      $('#trackModalProfile').val(1)
      $('#trackModalGain').val(0).attr('disabled', true)
    else
      $('#trackModalProfile').val(101)
      $('#trackModalGain').val(10).attr('disabled', false)

  $('#trackModalSave').click ->
    track = {
      'num_channels': $('#trackModalChannels').val(),
      'profile_number': $('#trackModalProfile').val(),
      'gain': $('#trackModalGain').val()
    }
    tracks = $('#tracksTable').data('tracks')
    tracks.push track
    $('#tm_preset_tracks').val(JSON.stringify(tracks))
    bb.redraw_tracks_table()

$ ->
  register_handlers()
