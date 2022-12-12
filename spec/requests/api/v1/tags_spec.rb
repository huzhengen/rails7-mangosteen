require "rails_helper"

RSpec.describe "Tags", type: :request do
  describe "GET tags" do
    it "not logged in" do
      get "/api/v1/tags"
      expect(response).to have_http_status(401)
    end
    it "pagination" do
      user1 = User.create! email: "1@gmail.com"
      user2 = User.create! email: "2@gmail.com"
      11.times do |i|
        Tag.create! name: "tag#{i}", sign: "x", user_id: user1.id
      end
      11.times do |i|
        Tag.create! name: "tag#{i}", sign: "x", user_id: user2.id
      end

      get "/api/v1/tags", headers: user1.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 10

      get "/api/v1/tags?page=2", headers: user1.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 1
    end
  end
end
