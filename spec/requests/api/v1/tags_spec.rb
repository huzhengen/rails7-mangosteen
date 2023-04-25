require "rails_helper"

RSpec.describe "Tags", type: :request do
  describe "GET tags" do
    it "not logged in" do
      get "/api/v1/tags"
      expect(response).to have_http_status(401)
    end
    it "pagination" do
      user1 = create :user
      user2 = create :user
      11.times do |i|
        create :tag, name: "tag#{i}", sign: "x", user: user1
      end
      11.times do |i|
        create :tag, name: "tag#{i}", sign: "x", user: user2
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
    it "get tags by kind" do
      user1 = create :user
      11.times do |i|
        Tag.create! name: "tag#{i}", sign: "x", kind: "expenses", user_id: user1.id
      end
      11.times do |i|
        Tag.create! name: "tag#{i}", sign: "x", kind: "income", user_id: user1.id
      end

      get "/api/v1/tags", headers: user1.generate_auth_header, params: { kind: "expenses" }
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 10

      get "/api/v1/tags", headers: user1.generate_auth_header, params: { kind: "expenses", page: 2 }
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
      user1 = create :user
      post "/api/v1/tags", params: { name: "name", sign: "sign" }, headers: user1.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json["resource"]["name"]).to eq "name"
      expect(json["resource"]["sign"]).to eq "sign"
    end
    it "need name when creating tag" do
      user1 = create :user
      post "/api/v1/tags", params: { sign: "sign" }, headers: user1.generate_auth_header
      expect(response).to have_http_status(422)
      json = JSON.parse(response.body)
      expect(json["errors"]["name"]).to be_an Array
      expect(json["errors"]["name"][0]).to eq "required"
    end
    it "need sign when creating tag" do
      user1 = create :user
      post "/api/v1/tags", params: { name: "name" }, headers: user1.generate_auth_header
      expect(response).to have_http_status(422)
      json = JSON.parse(response.body)
      expect(json["errors"]["sign"]).to be_an Array
      expect(json["errors"]["sign"][0]).to eq "required"
    end
  end

  describe "update tag" do
    it "not logged in" do
      user1 = create :user
      tag = Tag.create! name: "x", sign: "x", user_id: user1.id
      patch "/api/v1/tags/#{tag.id}", params: { name: "y", sign: "y" }
      expect(response).to have_http_status(401)
    end
    it "update tag" do
      user1 = create :user
      tag = Tag.create! name: "x", sign: "x", user_id: user1.id
      patch "/api/v1/tags/#{tag.id}", params: { name: "y", sign: "y" }, headers: user1.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json["resource"]["name"]).to eq "y"
      expect(json["resource"]["sign"]).to eq "y"
    end
    it "update name of tag only" do
      user1 = create :user
      tag = Tag.create! name: "x", sign: "x", user_id: user1.id
      patch "/api/v1/tags/#{tag.id}", params: { name: "y" }, headers: user1.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json["resource"]["name"]).to eq "y"
      expect(json["resource"]["sign"]).to eq "x"
    end
  end

  describe "delete a tag" do
    it "not logged in" do
      user1 = create :user
      tag = Tag.create! name: "x", sign: "x", user_id: user1.id
      delete "/api/v1/tags/#{tag.id}"
      expect(response).to have_http_status(401)
    end
    it "delete a tag" do
      user1 = create :user
      tag = Tag.create! name: "x", sign: "x", user_id: user1.id
      delete "/api/v1/tags/#{tag.id}", headers: user1.generate_auth_header
      expect(response).to have_http_status(200)
      tag.reload
      expect(tag.deleted_at).not_to eq nil
    end
    it "delete others' tag" do
      user1 = create :user
      user2 = create :user
      tag1 = Tag.create! name: "1", sign: "1", user_id: user1.id
      tag2 = Tag.create! name: "2", sign: "2", user_id: user2.id
      delete "/api/v1/tags/#{tag2.id}", headers: user1.generate_auth_header
      expect(response).to have_http_status(403)
    end
  end

  describe "get one tag" do
    it "not logged in" do
      user1 = create :user
      tag = Tag.create! name: "x", sign: "x", user_id: user1.id
      get "/api/v1/tags/#{tag.id}"
      expect(response).to have_http_status(401)
    end
    it "get one tag" do
      user1 = create :user
      tag = Tag.create! name: "x", sign: "x", user_id: user1.id
      get "/api/v1/tags/#{tag.id}", headers: user1.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json["resource"]["id"]).to eq tag.id
      expect(json["resource"]["name"]).to eq "x"
      expect(json["resource"]["sign"]).to eq "x"
    end
    it "get others' tag" do
      user1 = create :user
      user2 = create :user
      tag1 = Tag.create! name: "1", sign: "1", user_id: user1.id
      tag2 = Tag.create! name: "2", sign: "2", user_id: user2.id
      get "/api/v1/tags/#{tag2.id}", headers: user1.generate_auth_header
      expect(response).to have_http_status(403)
    end
  end
end
