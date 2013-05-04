class TMSource
  include ActiveAttr::Model

  attribute :id
  attribute :name
  attribute :host, default: '192.168.1.2'
  attribute :port, default: 3000

  validates_presence_of :name, :host, :port

end