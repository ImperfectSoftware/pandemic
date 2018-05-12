Fabricator(:user) do
  email { Faker::Internet.email }
  username { Faker::Name.unique.first_name }
  password { Faker::Internet.password }
end
