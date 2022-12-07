require "rails_helper"

RSpec.describe "ValidationCodes", type: :request do
  describe "Code" do
    it "can send code" do
      post "/api/v1/validation_codes", params: { email: "1@gmail.com" }
      expect(response).to have_http_status(200)
    end
    it "send frequent code" do
      post "/api/v1/validation_codes", params: { email: "1@gmail.com" }
      expect(response).to have_http_status(200)
      post "/api/v1/validation_codes", params: { email: "1@gmail.com" }
      expect(response).to have_http_status(429)
    end
  end
end
