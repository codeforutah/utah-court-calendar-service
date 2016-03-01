FactoryGirl.define do
  factory :developer_account do
    email "api_consumer@codeforamerica.org"
    password "password"
    password_confirmation "password"
  end
end
