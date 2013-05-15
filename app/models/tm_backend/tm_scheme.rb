class TMScheme
  include ActiveAttr::Model

  attribute :id
  attribute :name
  attribute :audio_mappings
  attribute :src1_id
  attribute :src1_name
  attribute :src2_id
  attribute :src2_name
  attribute :preset_id
  attribute :preset_name


  validates_presence_of :name

end