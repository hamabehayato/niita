require "rails_helper"

RSpec.describe "Api::V1::Articles::Drafts", type: :request do
  let(:current_user) { create(:user) }
  let!(:headers) { current_user.create_new_auth_token }

  # indexのテスト
  describe "GET /api/v1/articles/drafts" do
    subject { get(api_v1_articles_drafts_path, headers: headers) }

    let!(:article1) { create(:article, :draft, user: current_user, updated_at: 2.days.ago) }
    let!(:article2) { create(:article, :draft, user: current_user, updated_at: 1.days.ago) }
    let!(:article3) { create(:article, :draft, user: current_user) }

    before { create(:article, :published, user: current_user) }

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

  # showのテスト
  describe "GET /api/v1/articles/drafts/:id", type: :request do
    subject { get(api_v1_articles_draft_path(article_id), headers: headers) }

    context "指定した id の記事が存在する かつ" do
      let(:article_id) { article.id }

      context "自分が書いた下書きの記事であるとき" do
        let(:article) { create(:article, :draft, user: current_user) }

        it "その記事を表示する" do
          subject
          res = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(res["id"]).to eq article.id
          expect(res["title"]).to eq article.title
          expect(res["body"]).to eq article.body
          expect(res["updated_at"]).to be_present
          expect(res["user"]["id"]).to eq article.user.id
          expect(res["user"].keys).to eq ["id", "name", "email"]
        end
      end

      context "記事がの公開状態のとき" do
        let(:article) { create(:article, :published) }

        it "記事を表示しない" do
          expect { subject }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end

    context "指定した id の記事が存在しないとき" do
      let(:article_id) { 10000 }
      let(:article) { create(:article, :draft) }
      it "記事が見つからない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
