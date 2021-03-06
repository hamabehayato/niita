FactoryBot.define do
  factory :article do
    title {Faker::Base.regexify("[aあ]{30}")}
    body {Faker::Base.regexify("[bい]{400}")}
    user
  end

  factory :article_title_over, class: Article do
    title { Faker::Lorem.characters(number: Random.new.rand(31..100)) }
    body {Faker::Base.regexify("[bい]{400}")}
    user
  end

  factory :article_body_over, class: Article do
    title {Faker::Base.regexify("[aあ]{30}")}
    body { Faker::Lorem.characters(number: Random.new.rand(400..1000)) }
    user
  end
end
