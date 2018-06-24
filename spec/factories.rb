FactoryBot.define do
  factory :kudo do
    
  end
  factory :comment do
    
  end
  factory :bookmark do
    
  end
  factory :user do
    name 'TestUser'
    email 'test@example.com'
    password 'f4k3p455w0rd'

    # if needed
    is_active true
  end
end