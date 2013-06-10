class TMSlot
  include ActiveAttr::Model

  attribute :id
  attribute :slot_id
  attribute :scheme_id
  attribute :scheme_name
  attribute :transcoder_id
  attribute :transcoder_name

  validates_presence_of :slot_id, :scheme_id

  def <=>(other)
    if transcoder_id == other.transcoder_id
      slot_id <=> other.slot_id
    else
      transcoder_id <=> other.transcoder_id
    end
  end
end