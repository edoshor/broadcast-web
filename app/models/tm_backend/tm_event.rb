class TMEvent
  include ActiveAttr::Model

  attribute :id
  attribute :name

  validates_presence_of :name

end