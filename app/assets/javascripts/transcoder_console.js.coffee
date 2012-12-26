# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
  register_handlers()

register_handlers = () ->
  $('#run_command').click ->
    $('#ajax-loader').show()
    $.post("/transcoder_console/perform", $("#perform").serialize(),
    (data) ->
      $('#results').prepend(data)

      #    Show data according to checkboxes
      $('.result').show() if ($('#show_output').is(':checked'))
      $('.command').show() if $('#show_command').is(':checked')
      $('.response').show() if $('#show_response').is(':checked')

      $('#ajax-loader').hide()

      return false
    )

  $('#show_output').change ->
    if $('#show_output').is(':checked')
      $('.result').show()
    else
      $('.result').hide()

  $('#show_command').change ->
    if $('#show_command').is(':checked')
      $('.command').show()
    else
      $('.command').hide()

  $('#show_response').change ->
    if $('#show_response').is(':checked')
      $('.response').show()
    else
      $('.response').hide()

  $('#clear-log').click ->
    $('#results').html('')
