class Article < ApplicationRecord
  validates :title, presence: true, length: { maximum: 100 }
  validates :body,  presence: true

  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :article_likes, dependent: :destroy

  enum status: { draft: 0, published: 1 }
end
