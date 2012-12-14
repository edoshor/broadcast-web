class SlotPreset < ActiveRecord::Base
  belongs_to :transcoder
  belongs_to :preset
  attr_accessible :slot_id
end
