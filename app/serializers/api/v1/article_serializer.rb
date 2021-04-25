class Api::V1::ArticleSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :updated_at, :user, :status

  belongs_to :user, serializer: Api::V1::UserSerializer
end
