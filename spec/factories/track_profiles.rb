# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :track_profile do
    profile_number 1
    num_channels 1
    gain 1
    preset nil
  end
end
