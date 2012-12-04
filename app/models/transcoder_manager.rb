class TranscoderManager
  include Singleton

  def initialize()
    @transcoder_wrappers = {
        main: TranscoderWrapper.new(
            Transcoder.new(
                host: GlobalConstants::TRANSCODER_HOST,
                port: GlobalConstants::TRANSCODER_PORT))
    }
  end

  def get_transcoder(key)
    @transcoder_wrappers[key]
  end

  def set_transcoder(key, transcoder)
    @transcoder_wrappers[key] = transcoder
  end

end