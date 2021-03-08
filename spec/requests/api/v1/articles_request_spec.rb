require "rails_helper"

RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET /api/v1/articles" do
    subject { get(api_v1_articles_path) }

    let!(:article1) { create(:article, updated_at: 2.days.ago) }
    let!(:article2) { create(:article, updated_at: 1.days.ago) }
    let!(:article3) { create(:article) }

    it "記事一覧が取得できる" do
      subject
      res = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(res.length).to eq 3
      expect(res.map {|a| a["id"] }).to eq [article3.id, article2.id, article1.id]
      expect(res[0].keys).to eq ["id", "title", "updated_at", "user"]
      expect(res[0]["user"].keys).to eq ["id", "name", "email"]
    end
  end

  # describe "GET api/v1/article", type: :request do
  #     subject { get(api_v1_article_path(article_id)) }

  #     context "指定した id の記事が存在するとき" do
  #         let (:article_id) { article.id }
  #         let (:article) { create(:article) }

  #         fit "その記事を表示する" do
  #             subject
  #             binding.pry
  #         end
  #     end

  #     context "指定した id の記事が存在しないとき" do
  #         it "記事が見つからない" do
  #             subject
  #         end
  #     end
  # end
end
