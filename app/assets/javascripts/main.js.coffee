window.bb ?= {} # create bb namespace if it doesn't already exist

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