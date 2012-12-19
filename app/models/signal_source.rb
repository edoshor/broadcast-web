class SignalSource < ActiveRecord::Base
  attr_accessible :name, :ip, :port

  def self.find_by_ip_and_port(ip, port)
    where(ip: ip, port: port)
  end
end
