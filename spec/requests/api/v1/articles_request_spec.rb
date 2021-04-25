require "rails_helper"

RSpec.describe "Api::V1::Articles", type: :request do
  # indexのテスト
  describe "GET /api/v1/articles" do
    subject { get(api_v1_articles_path) }

    let!(:article1) { create(:article, :published, updated_at: 2.days.ago) }
    let!(:article2) { create(:article, :published, updated_at: 1.days.ago) }
    let!(:article3) { create(:article, :published) }

    before { create(:article, :draft) }

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
  describe "GET api/v1/articles/:id", type: :request do
    subject { get(api_v1_article_path(article_id)) }

    context "指定した id の記事が存在する かつ" do
      let(:article_id) { article.id }

      context "公開中の記事であるとき" do
        let(:article) { create(:article, :published) }

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

      context "記事が下書きのとき" do
        let(:article) { create(:article, :draft) }

        it "記事が見つからない" do
          expect { subject }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end

    context "指定した id の記事が存在しないとき" do
      let(:article_id) { 10000 }
      it "記事が見つからない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  # createのテスト
  describe "POST /api/v1/articles" do
    subject { post(api_v1_articles_path, params: params, headers: headers) }

    let(:user) { create(:user) }
    let!(:headers) { user.create_new_auth_token }

    context "title, body,を入力し、下書きを選択したとき" do
      let(:params) { { article: attributes_for(:article, status: "draft") } }

      it "下書き状態の記事レコードが作成できる" do
        expect { subject }.to change { Article.where(user_id: user.id).count }.by(1)
        res = JSON.parse(response.body)
        expect(res["title"]).to eq params[:article][:title]
        expect(res["body"]).to eq params[:article][:body]
        expect(res["status"]).to eq "draft"
        expect(response).to have_http_status(:ok)
      end
    end

    context "title, body,を入力し、公開を選択したとき" do
      let(:params) { { article: attributes_for(:article, status: "published") } }

      it "公開状態の記事レコードが作成できる" do
        expect { subject }.to change { Article.where(user_id: user.id).count }.by(1)
        res = JSON.parse(response.body)
        expect(res["title"]).to eq params[:article][:title]
        expect(res["body"]).to eq params[:article][:body]
        expect(res["status"]).to eq "published"
        expect(response).to have_http_status(:ok)
      end
    end

    context "でたらめな指定で記事を作成するとき" do
      let(:params) { { article: attributes_for(:article, status: :foo) } }

      it "エラーになる" do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end

  # 　updateのテスト
  describe "PATCH /api/v1/articles/:id" do
    subject { patch(api_v1_article_path(article.id), params: params, headers: headers) }

    let(:params) { { article: attributes_for(:article) } }
    let(:user) { create(:user) }
    let!(:headers) { user.create_new_auth_token }

    context "自分が所持している記事のレコードを下書き状態で更新しようとするとき" do
      let(:article) { create(:article, user: user, status: "draft") }
      it "記事を更新できる" do
        expect { subject }.to change { article.reload.title }.from(article.title).to(params[:article][:title]) &
                              change { article.reload.body }.from(article.body).to(params[:article][:body])
        res = JSON.parse(response.body)
        expect(res["status"]).to eq "draft"
        expect(response).to have_http_status(:ok)
      end
    end

    context "自分が所持している記事のレコードを公開状態で更新しようとするとき" do
      let(:article) { create(:article, user: user, status: "published") }
      it "記事を更新できる" do
        expect { subject }.to change { article.reload.title }.from(article.title).to(params[:article][:title]) &
                              change { article.reload.body }.from(article.body).to(params[:article][:body])
        res = JSON.parse(response.body)
        expect(res["status"]).to eq "published"
        expect(response).to have_http_status(:ok)
      end
    end

    context "自分が所持していない記事のレコードを更新しようとするとき" do
      let(:other_user) { create(:user) }
      let!(:article) { create(:article, user: other_user) }

      it "更新できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound) &
                              change { Article.count }.by(0)
      end
    end
  end

  # deleteのテスト
  describe "DELETE /articles/:id" do
    subject { delete(api_v1_article_path(article_id), headers: headers) }

    # devise_token_auth の導入が完了後に削除
    let(:user) { create(:user) }
    let(:article_id) { article.id }
    let!(:headers) { user.create_new_auth_token }

    context "自分の記事を削除しようとするとき" do
      let!(:article) { create(:article, user: user) }

      it "記事を削除できる" do
        expect { subject }.to change { Article.count }.by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context "他人が所持している記事のレコードを削除しようとするとき" do
      let(:other_user) { create(:user) }
      let!(:article) { create(:article, user: other_user) }

      it "記事を削除できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound) &
                              change { Article.count }.by(0)
      end
    end
  end
end
