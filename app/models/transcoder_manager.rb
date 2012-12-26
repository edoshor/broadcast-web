class TranscoderManager
  include Singleton

  attr_accessor :master, :slave

  def initialize()
    @transcoders = Transcoder.all
    @sources = SignalSource.all
    @presets = Preset.includes(:track_profiles, :track_mappings).all

    @master = Transcoder.where(master: true).first!
    @slave = Transcoder.where(slave: true).first!

  end

  def has_source? (name)
    @sources.any? { |source| source.name == name }
  end

  def get_source(name)
    @sources.find { |source| source.name == name }
  end

  def get_source_by_address(ip, port)
    @sources.find { |source| source.ip == ip && source.port == port }
  end

  def has_preset? (name)
    @presets.any? { |preset| preset.name == name }
  end

  def get_preset(name)
    @presets.find { |preset| preset.name == name }
  end

  def get_preset_by_id(id)
    @presets.find { |preset| preset.id == id }
  end

  def random_preset
    @presets[rand(@presets.size)]
  end

  def load_source(name)
    slot_id = 254
    TranscoderApiCommand.new(
        TranscoderApi::MOD_CREATE_SLOT, {slot_id: slot_id, preset: get_preset('preset1')}).execute(@slave)

    source = get_source name
    TranscoderApiCommand.new(
        TranscoderApi::MOD_SLOT_CMD,
        {slot_cmd: TranscoderApi::CMD_SLOT_RESTART,
         slot_id: slot_id, primary_source: source, secondary_source: source})
    .execute(@slave)
  end

  def unload_source
    slot_id = 254
    TranscoderApiCommand.new(TranscoderApi::MOD_SLOT_CMD,
                             {slot_cmd: TranscoderApi::CMD_SLOT_STOP, slot_id: slot_id}).execute(@slave)
    TranscoderApiCommand.new(TranscoderApi::MOD_REMOVE_SLOT, {slot_id: slot_id}).execute(@slave)
  end

end