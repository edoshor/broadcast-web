class TranscoderManager
  include Singleton

  def initialize()
    @transcoders = Transcoder.all
    @sources = SignalSource.all
    @presets = Preset.includes(:track_profiles, :track_mappings).all
  end

  def get_transcoder(key)
    @transcoders.find {|transcoder| transcoder.key == key}
  end

  def has_source? (name)
    @sources.any? {|source| source.name == name}
  end

  def get_source(name)
    @sources.find {|source| source.name == name}
  end

  def get_source_by_address(ip, port)
    @sources.find {|source| source.ip == ip && source.port == port}
  end

  def has_preset? (name)
    @presets.any? {|preset| preset.name == name}
  end

  def get_preset(name)
    @presets.find {|preset| preset.name == name}
  end

  def get_preset_by_id(id)
    @presets.find {|preset| preset.id == id}
  end

  def random_preset
    @presets[rand(@presets.size)]
  end

end