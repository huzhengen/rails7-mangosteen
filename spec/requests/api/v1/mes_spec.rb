require "rails_helper"

RSpec.describe "Me", type: :request do
  describe "Get current user" do
    it "Get user after sign in" do
      user = User.create! email: "1@gmail.com"
      post "/api/v1/session", params: { email: "1@gmail.com", code: "123456" }
      json = JSON.parse response.body
      jwt = json["jwt"]
      get "/api/v1/me", headers: { 'Authorization': "Bearer #{jwt}" }
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      # expect(json["resource"]["id"]).to be_a(Integer)
      expect(json["resource"]["id"]).to eq user.id
    end
  end
end
