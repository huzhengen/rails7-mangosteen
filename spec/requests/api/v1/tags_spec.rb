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
      create_list :tag, Tag.default_per_page + 1, user: user1
      create_list :tag, Tag.default_per_page + 1, user: user2
      get "/api/v1/tags", headers: user1.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq Tag.default_per_page

      get "/api/v1/tags?page=2", headers: user1.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 1
    end
    it "get tags by kind" do
      user1 = create :user
      create_list :tag, Tag.default_per_page + 1, user: user1
      create_list :tag, Tag.default_per_page + 1, user: user1, kind: "income"

      get "/api/v1/tags", headers: user1.generate_auth_header, params: { kind: "expenses" }
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq Tag.default_per_page

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
      post "/api/v1/tags", params: { name: "name", sign: "sign", kind: "expenses" }, headers: user1.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json["resource"]["name"]).to eq "name"
      expect(json["resource"]["sign"]).to eq "sign"
    end
    it "need name when creating tag" do
      user1 = create :user
      post "/api/v1/tags", params: { sign: "sign", kind: "expenses" }, headers: user1.generate_auth_header
      expect(response).to have_http_status(422)
      json = JSON.parse(response.body)
      expect(json["errors"]["name"]).to be_an Array
      expect(json["errors"]["name"][0]).to be_a String
    end
    it "need sign when creating tag" do
      user1 = create :user
      post "/api/v1/tags", params: { name: "name", kind: "expenses" }, headers: user1.generate_auth_header
      expect(response).to have_http_status(422)
      json = JSON.parse(response.body)
      expect(json["errors"]["sign"]).to be_an Array
      expect(json["errors"]["sign"][0]).to be_a String
    end
  end

  describe "update tag" do
    it "not logged in" do
      tag = create :tag
      patch "/api/v1/tags/#{tag.id}", params: { name: "y", sign: "y" }
      expect(response).to have_http_status(401)
    end
    it "update tag" do
      tag = create :tag
      patch "/api/v1/tags/#{tag.id}", params: { name: "y", sign: "y" }, headers: tag.user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json["resource"]["name"]).to eq "y"
      expect(json["resource"]["sign"]).to eq "y"
    end
    it "update name of tag only" do
      tag = create :tag
      patch "/api/v1/tags/#{tag.id}", params: { name: "y" }, headers: tag.user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json["resource"]["name"]).to eq "y"
      expect(json["resource"]["sign"]).to eq tag.sign
    end
  end

  describe "delete a tag" do
    it "not logged in" do
      tag = create :tag
      delete "/api/v1/tags/#{tag.id}"
      expect(response).to have_http_status(401)
    end
    it "delete a tag" do
      tag = create :tag
      delete "/api/v1/tags/#{tag.id}", headers: tag.user.generate_auth_header
      expect(response).to have_http_status(200)
      tag.reload
      expect(tag.deleted_at).not_to eq nil
    end
    it "delete others' tag" do
      tag1 = create :tag
      tag2 = create :tag
      delete "/api/v1/tags/#{tag2.id}", headers: tag1.user.generate_auth_header
      expect(response).to have_http_status(403)
    end
    it "delete tag and corresponding bookkeeping" do
      user = create :user
      tag = create :tag, user: user
      create_list :item, 2, user: user, tag_ids: [tag.id]
      expect {
        delete "/api/v1/tags/#{tag.id}?with_items=true", headers: user.generate_auth_header
      }.to change { Item.count }.by -2
      expect(response).to have_http_status(200)
      tag.reload
      expect(tag.deleted_at).not_to eq nil
    end
  end

  describe "get one tag" do
    it "not logged in" do
      tag = create :tag
      get "/api/v1/tags/#{tag.id}"
      expect(response).to have_http_status(401)
    end
    it "get one tag" do
      tag = create :tag
      get "/api/v1/tags/#{tag.id}", headers: tag.user.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json["resource"]["id"]).to eq tag.id
      expect(json["resource"]["name"]).to eq tag.name
      expect(json["resource"]["sign"]).to eq tag.sign
    end
    it "get others' tag" do
      tag1 = create :tag
      tag2 = create :tag
      get "/api/v1/tags/#{tag2.id}", headers: tag1.user.generate_auth_header
      expect(response).to have_http_status(403)
    end
  end
end
