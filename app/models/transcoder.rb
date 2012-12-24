class Transcoder < ActiveRecord::Base
  after_find :init_transcoder

  # attributes

  has_many :slot_presets, dependent: :destroy

  attr_accessible :host, :port

  attr_accessor :api

  # callbacks

  def init_transcoder
    @api = TranscoderApi.new(host: host, port: port)
  end

  # public methods

  def current_slot_ids
    result = TranscoderApiCommand.new(TranscoderApi::MOD_GET_SLOTS, {}).execute self
    ids = result[:error] == TranscoderApi::RET_OK ? result[:result][:slots_ids] : nil
    ids.nil? ? [] : ids
  end

  def get_status
    current_slot_ids.map { |id|
      TranscoderApiCommand.new(TranscoderApi::MOD_SLOT_CMD,
                               {slot_cmd: TranscoderApi::CMD_SLOT_GET_STATUS, slot_id: id}) }
    .map {|api_cmd| [api_cmd, api_cmd.execute(self)]}
    .each do |cmd, result|
      slot_id = cmd.args[:slot_id]
      result[:slot_id] = slot_id
      result[:preset] = slot_preset(slot_id).name
      result[:link] = slot_link slot_id
    end
  end

  def create_slot(slot_id, preset)
    slot_preset = slot_presets.where(slot_id: slot_id).first_or_create!
    slot_preset.preset_id = preset.id
    slot_preset.save!
  end

  def remove_slot(slot_id)
    slot_presets.where(slot_id: slot_id).destroy_all
  end

  def slot_preset(slot_id)
    preset_id = slot_presets.where(slot_id: slot_id).first!.preset_id
    preset = TranscoderManager.instance.get_preset_by_id(preset_id)
    preset.nil? ? Preset.find(preset_id) : preset
  end

  def slot_link(slot_id)
    "http://#{host}:#{8000 + slot_id}"
  end

end
