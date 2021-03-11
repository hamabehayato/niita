require "rails_helper"

RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET /articles" do
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

  describe "GET /article", type: :request do
    subject { get(api_v1_article_path(article_id)) }

    context "指定した id の記事が存在するとき" do
      let(:article_id) { article.id }
      let(:article) { create(:article) }

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

    context "指定した id の記事が存在しないとき" do
      let(:article_id) { 10000 }
      it "記事が見つからない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

    describe "POST /articles" do
        subject { post(api_v1_articles_path, params: params) }

        let(:params) { { article: attributes_for(:article) } }
        let(:current_user) { create(:user) }

        # stub
        before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) }

        it "記事のレコードが作成できる" do
        expect { subject }.to change { Article.where(user_id: current_user.id).count }.by(1)
        res = JSON.parse(response.body)
        expect(res["title"]).to eq params[:article][:title]
        expect(res["body"]).to eq params[:article][:body]
        expect(response).to have_http_status(:ok)
        end
    end

    describe "PATCH(PUT) /articles/:id" do
        subject { patch(api_v1_article_path(article.id), params: params) }

        let(:params) { { article: attributes_for(:article) } }
        let(:current_user) { create(:user) }
        # let!(:article) { create(:article) }

        before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) }

        context "自分が所持している記事のレコードを更新しようとするとき" do
            let(:article) {create(:article, user: current_user)}

            it "記事を編集する" do
            expect { subject }.to change { article.reload.title }.from(article.title).to(params[:article][:title]) &
                                  change { article.reload.body }.from(article.body).to(params[:article][:body])
            expect(response).to have_http_status(:ok)
            end
        end

        context "自分が所持していない記事のレコードを更新しようとするとき" do
            let(:other_user) { create(:user) }
            let!(:article) { create(:article, user: other_user) }

            it "記事を編集できない" do
                expect { subject }.to raise_error(ActiveRecord::RecordNotFound) &
                                      change { Article.count }.by(0)
            end
        end
    end

    describe "DELETE /articles/:id" do
        subject { delete(api_v1_article_path(article_id)) }
        let(:current_user) { create(:user) }
        let!(:article_id) { article.id }

        before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) }       

        context "自分の記事を削除しようとするとき" do
            let!(:article) { create(:article, user: current_user) }

            it "記事を削除する" do
                expect { subject }.to change { Article.count }.by(-1)
                expect(response).to have_http_status(204)
                binding.pry
            end
        end

        context "自分以外の記事を削除しようとするとき" do
            let(:other_user) { create(:user) }
            let!(:article) { create(:article, user: other_user) }
            
            it "記事を削除出来ない" do
                expect { subject }.to raise_error(ActiveRecord::RecordNotFound) &
                                      change { Article.count }.by(0)
            end
        end
    end

end
