class TMSlot
  include ActiveAttr::Model

  attribute :id
  attribute :slot_id
  attribute :scheme_id
  attribute :scheme_name

  validates_presence_of :slot_id, :scheme_id

  def <=>(other)
    slot_id <=> other.slot_id
  end
end