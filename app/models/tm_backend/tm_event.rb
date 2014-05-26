class TMEvent
  include ActiveAttr::Model

  attribute :id
  attribute :name
  attribute :csid

  validates_presence_of :name, :csid

end