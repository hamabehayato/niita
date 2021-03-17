class Article < ApplicationRecord
  validates :title, presence: true, length: { maximum: 30 }
  validates :body,  presence: true, length: { maximum: 400 }

  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :article_likes, dependent: :destroy

  enum status: { draft: 0, published: 1 }

end
