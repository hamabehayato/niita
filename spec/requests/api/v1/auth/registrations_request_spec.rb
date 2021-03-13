require "rails_helper"

RSpec.describe "Api::V1::Auth::Registrations", type: :request do
  describe "POST api/v1/auth" do
    subject { post(api_v1_user_registration_path, params: params) }

    let(:params) { attributes_for(:user) }

    context "正しい値が入力された時" do
      it "ユーザ登録出来る" do
        subject
        res = JSON.parse(response.body)
        expect(res["status"]).to eq("success")
        expect(res["data"]["id"]).to eq(User.last.id)
        expect(res["data"]["email"]).to eq(User.last.email)
        expect(response).to have_http_status(:ok)
      end

      it "ヘッダー情報を取得できる" do
        subject
        header = response.header
        expect(header["uid"]).to be_present
        expect(header["access-token"]).to be_present
        expect(header["token-type"]).to be_present
        expect(header["client"]).to be_present
        expect(header["Content-Type"]).to be_present
        expect(header["ETag"]).to be_present
        expect(header["expiry"]).to be_present
      end
    end

    context "nameが入力されていないとき" do
      let(:params) { attributes_for(:user, name: nil) }

      it "ユーザが作成されない" do
        expect { subject }.to change { User.count }.by(0)
      end
    end

    context "emailが入力されていないとき" do
      let(:params) { attributes_for(:user, email: nil) }

      it "ユーザが作成されない" do
        expect { subject }.to change { User.count }.by(0)
      end
    end

    context "passwordが入力されていないとき" do
      let(:params) { attributes_for(:user, password: nil) }

      it "ユーザが作成されない" do
        expect { subject }.to change { User.count }.by(0)
      end
    end
  end
end
