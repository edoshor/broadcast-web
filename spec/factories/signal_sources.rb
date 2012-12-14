# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :signal_source do
    ip1 "MyString"
    port1 1
    ip2 "MyString"
    port2 "MyString"
  end
end
