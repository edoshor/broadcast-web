class Transcoder < ActiveRecord::Base
  after_find :init_transcoder

  # attributes

  has_many :slot_presets, :dependent => :destroy

  attr_accessible :key, :host, :port

  attr_reader :api

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

  def create_slot(slot_id, preset)
    slot_preset = slot_presets.where(slot_id: slot_id).first_or_create!
    slot_preset.preset = preset
    slot_preset.save!
  end

  def remove_slot(slot_id)
    slot_presets.where(slot_id: slot_id).destroy_all
  end

  def slot_preset(slot_id)
    # optimize: don't load preset from db every time, use TranscoderManager...
    slot_presets.where(slot_id: slot_id).first!.preset
  end

  def slot_link(slot_id)
    "http://#{host}:#{8000 + slot_id}"
  end


end
