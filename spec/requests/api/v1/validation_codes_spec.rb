require "rails_helper"

RSpec.describe "ValidationCodes", type: :request do
  describe "Code" do
    it "can send code" do
      post "/api/v1/validation_codes", params: { email: "1@gmail.com" }
      expect(response).to have_http_status(200)
    end
    it "send frequent code 429" do
      post "/api/v1/validation_codes", params: { email: "1@gmail.com" }
      expect(response).to have_http_status(200)
      post "/api/v1/validation_codes", params: { email: "1@gmail.com" }
      expect(response).to have_http_status(429)
    end
    it "email is not legal 422" do
      post "/api/v1/validation_codes", params: { email: "1" }
      expect(response).to have_http_status(422)
      json = JSON.parse(response.body)
      expect(json["errors"]["email"][0]).to be_a String
      expect(json["errors"]["email"][0]).to eq("is invalid")
    end
  end
end
