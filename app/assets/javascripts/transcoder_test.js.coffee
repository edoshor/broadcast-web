# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
  register_handlers()

register_handlers = () ->
  $('#run_commands').click ->
    $('#ajax-loader').show()
    $('#run_commands').attr("disabled", "disabled");
    $.post("/transcoder_test/perform", $("#perform").serialize(),
    (data) ->
      $('#commands').val('')
      $('#results').prepend(data)
      $('#ajax-loader').hide()
      $('#run_commands').removeAttr("disabled")
      $('#results').effect('highlight', 'slow')
      false
    )

  $('#clear-log').click ->
    $('#results').html('')

  setInterval(refresh_status, 2000)

refresh_status = () ->
  $.get("/transcoder_test/status",
    (data) ->
      $('#status').html(data)
  )
