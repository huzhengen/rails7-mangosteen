require "rails_helper"
require "active_support/testing/time_helpers"

RSpec.describe "Me", type: :request do
  include ActiveSupport::Testing::TimeHelpers
  describe "Get current user" do
    it "Get user after sign in" do
      user = User.create! email: "1@gmail.com"
      post "/api/v1/session", params: { email: "1@gmail.com", code: "123456" }
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      jwt = json["jwt"]
      get "/api/v1/me", headers: { 'Authorization': "Bearer #{jwt}" }
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      # expect(json["resource"]["id"]).to be_a(Integer)
      expect(json["resource"]["id"]).to eq user.id
    end
    it "jwt过期" do
      travel_to Time.now - 3.hours
      user1 = User.create! email: "1@gmail.com"
      jwt = user1.generate_jwt
      travel_back
      get "/api/v1/me", headers: { 'Authorization': "Bearer #{jwt}" }
      expect(response).to have_http_status(401)
    end
    it "jwt没过期" do
      travel_to Time.now - 1.hours
      user1 = User.create! email: "1@gmail.com"
      jwt = user1.generate_jwt
      travel_back
      get "/api/v1/me", headers: { 'Authorization': "Bearer #{jwt}" }
      expect(response).to have_http_status(200)
    end
  end
end
