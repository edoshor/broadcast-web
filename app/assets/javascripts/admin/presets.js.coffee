window.bb ?= {} # create bb namespace if it doesn't already exist

window.bb.remove_track = (row_id) ->
  $('#tracksTable').data('tracks').splice(row_id, 1)
  bb.redraw_tracks_table()

window.bb.redraw_tracks_table = () ->
  table = $('#tracksTable>tbody')
  tracks = $('#tracksTable').data('tracks')
  table.empty()
  for track, i in tracks
    row = "<tr>"
    row += "<td> #{ track.num_channels } </td>"
    row += "<td> #{ track.profile_number } </td>"
    row += "<td> #{ track.gain } </td>"
    row += "<td><a href='#' onclick='javascript:bb.remove_track(#{ i }); false;'>delete</a></td>"
    row += "</tr>"
    table.append(row)

register_handlers = () ->
  $('#tracksTable').data('tracks', [])

  $('#trackModalChannels').change ->
    if $(this).val() == '0'
      $('#trackModalGain').val(0)
      $('#trackModalProfile').val(1)
    else
      $('#trackModalGain').val(10)
      $('#trackModalProfile').val(101)

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
