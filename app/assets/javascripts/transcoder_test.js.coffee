# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
  register_handlers()

register_handlers = () ->
  $('#run_commands').click ->
    $('#ajax-loader').show()
    $.post("/transcoder_test/perform", $("#perform").serialize(),
    (data) ->
      $('#results').prepend(data)
      $('#ajax-loader').hide()
      $('#results').effect('highlight', 'slow')
      false
    )

  $('#clear-log').click ->
    $('#results').html('')
