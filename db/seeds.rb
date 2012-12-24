# Transcoders

[{host: '10.65.6.104', port: 10000, status_port: 11000, master: true, slave: false},
{host: '10.65.6.103', port: 10000, status_port: 11000, master: false, slave: true}]
.each do |details|
  transcoder = Transcoder.find_or_create_by_host details[:host]
  transcoder.port = details[:port]
  transcoder.status_port = details[:status_port]
  transcoder.master = details[:master]
  transcoder.slave = details[:slave]
  transcoder.save
end

# Signal sources

[{name: 'source1', ip: '192.168.1.2', port: 3000},
{name: 'source2', ip: '192.168.1.2', port: 3001},
{name: 'source3', ip: '192.168.1.2', port: 3002},
{name: 'source4', ip: '192.168.1.2', port: 3003}]
.each do |source_def|
  source = SignalSource.find_or_create_by_name source_def[:name]
  source.update_attributes source_def
end

# Presets

preset_tracks = {
    preset1: [[1, 0, 0],
              [101, 1, 10]],
    preset2: [[2, 0, 0],
              [102, 1, 10]],
    preset3: [[3, 0, 0],
              [102, 1, 10]],
    preset4: [[4, 0, 0],
              [103, 1, 10]],
    tv66: [[1, 0, 0],
             [101, 1, 10],
             [2, 0, 0],
             [3, 0, 0],
             [102, 1, 10],
             [101, 1, 10],
             [102, 1, 10]],
    tvrus: [[1, 0, 0],
              [101, 1, 10],
              [2, 0, 0],
              [3, 0, 0],
              [102, 1, 10]],
    live1: [[1, 0, 0],
             [101, 1, 10],
             [2, 0, 0],
             [3, 0, 0],
             [102, 1, 10],
             [101, 1, 10],
             [102, 1, 10],
             [101, 1, 10],
             [102, 1, 10],
             [101, 1, 10],
             [102, 1, 10],
             [101, 1, 10],
             [102, 1, 10],
             [101, 1, 10],
             [102, 1, 10],
             [101, 1, 10],
             [102, 1, 10]],
    live2: [[1, 0, 0],
            [101, 1, 10],
            [2, 0, 0],
            [3, 0, 0],
            [102, 1, 10],
            [101, 1, 10],
            [102, 1, 10],
            [101, 1, 10],
            [102, 1, 10],
            [101, 1, 10],
            [102, 1, 10],
            [101, 1, 10],
            [102, 1, 10],
            [101, 1, 10],
            [102, 1, 10]]
}

audio_channel_mappings = {
    preset1: [0, 1],
    preset2: [0, 1],
    preset3: [0, 1],
    preset4: [0, 1],
    tv66: [0, 1, 0, 0, 1, 2, 2],
    tvrus: [0, 1, 0, 0, 1],
    live1: [0, 1, 0, 0, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7],
    live2: [0, 1, 0, 0, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6]}

%w(preset1 preset2 preset3 preset4 tv66 tvrus live1 live2).each do |preset_name|
  preset = Preset.find_or_create_by_name(preset_name)
  preset.track_profiles.destroy_all
  preset.track_mappings.destroy_all

  input_channels = audio_channel_mappings[preset_name.to_sym]
  tracks = preset_tracks[preset_name.to_sym]
  tracks.zip(input_channels).each do |track, input|
    mapping = preset.track_mappings.create({input_track: input})
    mapping.track_profile = preset.track_profiles.create(
        {profile_number: track[0], num_channels: track[1], gain: track[2]})
    mapping.save!
  end
end

