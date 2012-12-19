class SlotPreset < ActiveRecord::Base
  belongs_to :transcoder
  attr_accessible :slot_id, :preset_id
end
