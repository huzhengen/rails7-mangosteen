require "rails_helper"

RSpec.describe "Sessions", type: :request do
  describe "Session" do
    it "Sign in" do
      user = create :user
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
    it "need email and code when sign in" do
      user = create :user
      post "/api/v1/session", params: {}
      expect(response).to have_http_status(422)
      json = JSON.parse response.body
      expect(json["errors"]["email"][0]).to eq "required"
      expect(json["errors"]["code"][0]).to eq "required"
    end
  end
end
