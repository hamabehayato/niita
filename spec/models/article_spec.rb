require "rails_helper"

RSpec.describe Article, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"

  # context "titleとbodyが入力されているとき" do
  #   it "articleが作られる" do
  #     user = create(:user)
  #     article = build(:article, user_id: user.id)
  #     expect(article).to be_valid
  #   end
  # end

  context "titleが入力されていないとき" do
    it "article作成に失敗する" do
      user = create(:user)
      article = build(:article, title: nil, user_id: user.id)
      expect(article).not_to be_valid
    end
  end

  context "bodyが入力されていないとき" do
    it "article作成に失敗する" do
      user = create(:user)
      article = build(:article, body: nil, user_id: user.id)
      expect(article).not_to be_valid
    end
  end

  context "titleが31文字以上入力されているとき" do
    it "article作成に失敗する" do
      user = create(:user)
      article = build(:article_title_over, user_id: user.id)
      # article = build(:article, :title, user_id: user.id)
      expect(article).not_to be_valid
    end
  end

  context "bodyが401文字以上入力されているとき" do
    it "article作成に失敗する" do
      user = create(:user)
      article = build(:article_body_over, user_id: user.id)
      # article = build(:article, :title, user_id: user.id)
      expect(article).not_to be_valid
    end
  end

  context "タイトルと本文が入力されているとき" do
    let(:article) { build(:article) }

    it "下書き状態の記事が作成できる" do
      expect(article).to be_valid
      expect(article.status).to eq "draft"
    end
  end

  context "下書きのとき" do
    let(:draft) { build(:article, :draft) }

    it "下書き記事を保存できる" do
      expect(draft).to be_valid
    end
  end

  context "公開記事のとき" do
    let(:published) { build(:article, :published) }

    it "公開記事を保存できる" do
      expect(published).to be_valid
    end
  end
end
