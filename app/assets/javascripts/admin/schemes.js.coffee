window.bb ?= {} # create bb namespace if it doesn't already exist

window.bb.draw_mappings_table = (preset) ->
  table = $('#mappingsTable>tbody')
  table.empty()
  for track, i in preset.tracks
    row = "<tr>"
    row += "<td><b>Channels: </b> #{ track.num_channels }, "
    row += "<b>Profile: </b> #{ track.profile_number }, "
    row += "<b>Gain: </b> #{ track.gain }</td>"

    row += "<td><input name='tm_scheme[audio_mappings][]'"
    if track.num_channels == 0
      row += "class='uneditable-input' value=0"
    else
      row += "class='string required'"

    row += " /></td></tr>"

    table.append(row)

register_handlers = () ->
  $('#tm_scheme_preset_id').change ->
    $('#tm_scheme_audio_mappings').val('')
    $.get('../presets/' + $(this).val(), bb.draw_mappings_table, "json")

$ ->
  register_handlers()
