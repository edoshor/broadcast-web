class TMTrack
  include ActiveAttr::Model

  attribute :id
  attribute :gain
  attribute :num_channels
  attribute :profile_number

  def human_num_channels
    num_channels == 0 ? 'Video' : 'Audio'
  end

  def human_profile_number
    num_channels == 0 ? human_video_profile : human_audio_profile
  end

  def human_video_profile
    case profile_number
      when 1
        '320x240, 120Kbit, 4:3'
      when 2
        '360x270, 200Kbit, 4:3'
      when 3
        '640x480, 400Kbit, 4:3'
      when 4
        '720x540, 600Kbit, 4:3'
      when 11
        '320x180, 120Kbit, 16:9'
      when 12
        '360x202, 200Kbit, 16:9'
      when 13
        '640x360, 400Kbit, 16:9'
      when 14
        '720x404, 600Kbit, 16:9'
      else
        profile_number
    end
  end

  def human_audio_profile
    case profile_number
      when 101
        'AAC, 32Kbit, mono'
      when 102
        'AAC, 48Kbit, mono'
      when 103
        'AAC, 96Kbit, stereo'
      else
        profile_number
    end
  end

end