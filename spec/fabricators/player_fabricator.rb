Fabricator(:player) do
  user { Fabricate(:user) }
  role { Role.all.sample.name }
end
