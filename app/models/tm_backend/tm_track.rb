class TMTrack
  include ActiveAttr::Model

  attribute :id
  attribute :gain
  attribute :num_channels
  attribute :profile_number

  def human_num_channels
    num_channels == 0 ? 'video' : 'audio'
  end

  def human_profile_number
    num_channels == 0 ? human_video_profile : human_audio_profile
  end

  def human_video_profile
    case profile_number
      when 1
        '320x240, 120Kbit'
      when 2
        '360x270, 200Kbit'
      when 3
        '640x480, 400Kbit'
      when 4
        '720x540, 600Kbit'
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