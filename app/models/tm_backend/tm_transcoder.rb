class TMTranscoder
  include ActiveAttr::Model

  attribute :id
  attribute :name
  attribute :host, default: '10.65.6.10x'
  attribute :port, default: 10000
  attribute :status_port, default: 11000

  validates_presence_of :name, :host

end