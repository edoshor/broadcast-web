class TranscoderWrapper

  attr_reader :slots_presets
  attr_accessor :transcoder

  def initialize(transcoder)
    @transcoder = transcoder
    @slots_presets = {}
  end


end