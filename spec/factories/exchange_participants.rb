FactoryBot.define do
  factory :exchange_participant do
    fullname { Faker::Name.name }
    cellphone { Faker::PhoneNumber.cell_phone }
    email { Faker::Internet.email }
    birthdate { Faker::Date.birthday(18, 30) }
    password { Faker::Internet.password }
    local_committee
    university
    college_course
    cellphone_contactable { false }
    scholarity { 1 }
  end
end
