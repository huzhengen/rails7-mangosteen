require "rails_helper"

RSpec.describe "ValidationCodes", type: :request do
  describe "Code" do
    it "can send code" do
      post "/api/v1/validation_codes", params: { email: "1@gmail.com" }
      expect(response).to have_http_status(200)
    end
  end
end
