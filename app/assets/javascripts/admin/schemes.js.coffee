window.bb ?= {}
bb.editMode = false

bb.draw_mappings_table = (preset) ->
  table = $('#mappingsTable').find('tbody')
  table.empty()
  for track, i in preset.tracks
    row = "<tr>"
    row += "<td> #{ bb.humanize_channels(track.num_channels) } </td>"
    row += "<td> #{ bb.humanize_profile(track.profile_number) } </td>"
    row += "<td>#{ track.gain }</td>"
    if track.num_channels == 0
      row += "<td><input type='hidden' name='tm_scheme[audio_mappings][]' value='0'/></td>"
    else
      row += '<td><select id="tm_scheme_audio_mappings"' +
      'class="select optional required"' +
      'name="tm_scheme[audio_mappings][]"' +
      'selected="selected">';
      row += ("<option value='#{i}'>#{i}</option>" for i in [0..preset.tracks.length-1])
      row += '</select></td>'
    row += "</tr>"
    table.append(row)


register_handlers = () ->
  $('#tm_scheme_preset_id').change ->
    rel = if bb.editMode then '../../' else '../'
    $.get(rel + 'presets/' + $(this).val(), bb.draw_mappings_table, "json")

$ ->
  register_handlers()