class Api::V1::ArticlePreviewSerializer < ActiveModel::Serializer
  attributes :id,
             :title,
             :body

  has_many :comments
  has_many :article_likes
end
