class TMSource
  include ActiveAttr::Model

  attribute :id
  attribute :name
  attribute :capture_id
  attribute :capture_name
  attribute :input

  validates_presence_of :name

end