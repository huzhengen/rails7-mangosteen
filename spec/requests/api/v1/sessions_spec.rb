require "rails_helper"

RSpec.describe "Sessions", type: :request do
  describe "Session" do
    it "Sign in" do
      user = User.create! email: "1@gmail.com"
      post "/api/v1/session", params: { email: "1@gmail.com", code: "123456" }
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json["jwt"]).to be_a(String)
    end
    it "First sign in" do
      post "/api/v1/session", params: { email: "1@gmail.com", code: "123456" }
      expect(response).to have_http_status(200)
      json = JSON.parse response.body
      expect(json["jwt"]).to be_a(String)
    end
  end
end
