require 'rails_helper'

RSpec.describe "Api::V1::Current::Articles", type: :request do

    let(:current_user) { create(:user) }
    let!(:headers) { article1.user.create_new_auth_token }
    
    # indexのテスト
    describe "GET /api/v1/current/articles" do
        subject { get(api_v1_current_articles_path, headers: headers) }
    
        let!(:article1) { create(:article, :published, user: current_user, updated_at: 2.days.ago) }
        let!(:article2) { create(:article, :published, user: current_user, updated_at: 1.days.ago) }
        let!(:article3) { create(:article, :published, user: current_user) }
    
        before do
            create(:article, :draft, user: current_user)
            create(:article, :published)
        end
    
        fit "記事一覧が取得できる" do
            subject
            res = JSON.parse(response.body)
            expect(response).to have_http_status(:ok)
            expect(res.length).to eq 3
            expect(res.map {|a| a["id"] }).to eq [article3.id, article2.id, article1.id]
            expect(res[0]["user"]["id"]).to eq current_user.id
            expect(res[0]["user"]["name"]).to eq current_user.name
            expect(res[0]["user"]["email"]).to eq current_user.email
        end
    end
end
