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
  describe "create tags" do
    it "not logged in" do
      post "/api/v1/tags", params: { name: "x", sign: "x" }
      expect(response).to have_http_status(401)
    end
    it "create tag" do
      user1 = User.create! email: "1@gmail.com"
      post "/api/v1/tags", params: { name: "name", sign: "sign" }, headers: user1.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json["resource"]["name"]).to eq "name"
      expect(json["resource"]["sign"]).to eq "sign"
    end
    it "need name when creating tag" do
      user1 = User.create! email: "1@gmail.com"
      post "/api/v1/tags", params: { sign: "sign" }, headers: user1.generate_auth_header
      expect(response).to have_http_status(422)
      json = JSON.parse(response.body)
      expect(json["errors"]["name"]).to be_an Array
      expect(json["errors"]["name"][0]).to eq "can't be blank"
    end
    it "need sign when creating tag" do
      user1 = User.create! email: "1@gmail.com"
      post "/api/v1/tags", params: { name: "name" }, headers: user1.generate_auth_header
      expect(response).to have_http_status(422)
      json = JSON.parse(response.body)
      expect(json["errors"]["sign"]).to be_an Array
      expect(json["errors"]["sign"][0]).to eq "can't be blank"
    end
  end

  describe "update tag" do
    it "not logged in" do
      user1 = User.create! email: "1@gmail.com"
      tag = Tag.create! name: "x", sign: "x", user_id: user1.id
      patch "/api/v1/tags/#{tag.id}", params: { name: "y", sign: "y" }
      expect(response).to have_http_status(401)
    end
    it "update tag" do
      user1 = User.create! email: "1@gmail.com"
      tag = Tag.create! name: "x", sign: "x", user_id: user1.id
      patch "/api/v1/tags/#{tag.id}", params: { name: "y", sign: "y" }, headers: user1.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json["resource"]["name"]).to eq "y"
      expect(json["resource"]["sign"]).to eq "y"
    end
    it "update name of tag only" do
      user1 = User.create! email: "1@gmail.com"
      tag = Tag.create! name: "x", sign: "x", user_id: user1.id
      patch "/api/v1/tags/#{tag.id}", params: { name: "y" }, headers: user1.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json["resource"]["name"]).to eq "y"
      expect(json["resource"]["sign"]).to eq "x"
    end
  end
end
