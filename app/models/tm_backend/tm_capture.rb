class TMCapture
  include ActiveAttr::Model

  attribute :id
  attribute :name
  attribute :host, default: '192.168.1.2'
  attribute :input1, default: 3000
  attribute :input2, default: 3001
  attribute :input3, default: 3002
  attribute :input4, default: 3003

  validates_presence_of :name, :host

end