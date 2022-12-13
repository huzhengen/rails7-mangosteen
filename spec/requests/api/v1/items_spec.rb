require "rails_helper"

RSpec.describe "Items", type: :request do
  describe "Get items" do
    it "not logged in" do
      get "/api/v1/items"
      expect(response).to have_http_status(401)
    end
    it "pagination" do
      user1 = User.create! email: "1@gmail.com"
      user2 = User.create! email: "2@gmail.com"
      tag1 = Tag.create! name: "name", sign: "sign", user_id: user1.id
      tag2 = Tag.create! name: "name", sign: "sign", user_id: user1.id
      11.times do
        Item.create! amount: 100, tags_id: [tag1.id, tag2.id], happen_at: Time.now, user_id: user1.id
      end
      11.times do
        Item.create! amount: 100, tags_id: [tag1.id, tag2.id], happen_at: Time.now, user_id: user2.id
      end
      get "/api/v1/items", headers: user1.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 10
      get "/api/v1/items?page=2", headers: user1.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 1
    end
    it "filter by time" do
      user1 = User.create! email: "1@gmail.com"
      tag1 = Tag.create! name: "name", sign: "sign", user_id: user1.id
      tag2 = Tag.create! name: "name", sign: "sign", user_id: user1.id
      item1 = Item.create amount: 100, tags_id: [tag1.id, tag2.id], happen_at: Time.now, created_at: "2018-01-02", user_id: user1.id
      item2 = Item.create amount: 100, tags_id: [tag1.id, tag2.id], happen_at: Time.now, created_at: "2018-01-02", user_id: user1.id
      item3 = Item.create amount: 100, tags_id: [tag1.id, tag2.id], happen_at: Time.now, created_at: "2019-01-01", user_id: user1.id
      get "/api/v1/items?created_after=2018-01-01&created_before=2018-01-03", headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 2
      expect(json["resources"][0]["id"]).to eq item1.id
      expect(json["resources"][1]["id"]).to eq item2.id
    end
    it "filter by time(boundary conditions)" do
      user1 = User.create! email: "1@gmail.com"
      tag1 = Tag.create! name: "name", sign: "sign", user_id: user1.id
      tag2 = Tag.create! name: "name", sign: "sign", user_id: user1.id
      item1 = Item.create amount: 100, tags_id: [tag1.id, tag2.id], happen_at: Time.now, created_at: "2018-01-01", user_id: user1.id
      get "/api/v1/items?created_after=2018-01-01&created_before=2018-01-02", headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 1
      expect(json["resources"][0]["id"]).to eq item1.id
    end
    it "filter by time(boundary conditions 2)" do
      user1 = User.create! email: "1@gmail.com"
      tag1 = Tag.create! name: "name", sign: "sign", user_id: user1.id
      tag2 = Tag.create! name: "name", sign: "sign", user_id: user1.id
      item1 = Item.create amount: 100, tags_id: [tag1.id, tag2.id], happen_at: Time.now, created_at: "2018-01-01", user_id: user1.id
      item2 = Item.create amount: 100, tags_id: [tag1.id, tag2.id], happen_at: Time.now, created_at: "2017-01-01", user_id: user1.id
      get "/api/v1/items?created_after=2018-01-01", headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 1
      expect(json["resources"][0]["id"]).to eq item1.id
    end
    it "filter by time(boundary conditions 3)" do
      user1 = User.create! email: "1@gmail.com"
      tag1 = Tag.create! name: "name", sign: "sign", user_id: user1.id
      tag2 = Tag.create! name: "name", sign: "sign", user_id: user1.id
      item1 = Item.create amount: 100, tags_id: [tag1.id, tag2.id], happen_at: Time.now, created_at: "2018-01-01", user_id: user1.id
      item2 = Item.create amount: 100, tags_id: [tag1.id, tag2.id], happen_at: Time.now, created_at: "2019-01-01", user_id: user1.id
      get "/api/v1/items?created_before=2018-01-02", headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 1
      expect(json["resources"][0]["id"]).to eq item1.id
    end
  end

  describe "Create one item" do
    it "not logged in" do
      post "/api/v1/items", params: { amount: 100 }
      expect(response).to have_http_status(401)
    end
    it "create one item" do
      user = User.create! email: "1@gmail.com"
      tag1 = Tag.create! name: "name", sign: "sign", user_id: user.id
      tag2 = Tag.create! name: "name", sign: "sign", user_id: user.id
      expect {
        post "/api/v1/items", params: { amount: 100, tags_id: [tag1.id, tag2.id], happen_at: "2018-01-01T00:00:00+08:00" },
                              headers: user.generate_auth_header
      }.to change { Item.count }.by 1
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json["resource"]["id"]).to be_an Numeric
      expect(json["resource"]["user_id"]).to eq user.id
      expect(json["resource"]["amount"]).to eq 100
      expect(json["resource"]["happen_at"]).to eq "2017-12-31T16:00:00.000Z"
    end
    it "need 'amount, tags_id, happen_at' when creating one item" do
      user = User.create! email: "1@gmail.com"
      tag = Tag.create! name: "name", sign: "sign", user_id: user.id
      post "/api/v1/items", params: {}, headers: user.generate_auth_header
      expect(response).to have_http_status(422)
      json = JSON.parse(response.body)
      expect(json["errors"]["amount"][0]).to eq "can't be blank"
      expect(json["errors"]["tags_id"][0]).to eq "can't be blank"
    end
  end

  describe "Statistics" do
    it "grouped by day/happen_at" do
      user = User.create! email: "1@gmail.com"
      tag = Tag.create! name: "name", sign: "sign", user_id: user.id
      Item.create! happen_at: "2018-06-18T00:00:00+08:00", amount: 100, tags_id: [tag.id], kind: "expenses", user_id: user.id
      Item.create! happen_at: "2018-06-18T00:00:00+08:00", amount: 200, tags_id: [tag.id], kind: "expenses", user_id: user.id
      Item.create! happen_at: "2018-06-20T00:00:00+08:00", amount: 100, tags_id: [tag.id], kind: "expenses", user_id: user.id
      Item.create! happen_at: "2018-06-20T00:00:00+08:00", amount: 200, tags_id: [tag.id], kind: "expenses", user_id: user.id
      Item.create! happen_at: "2018-06-19T00:00:00+08:00", amount: 100, tags_id: [tag.id], kind: "expenses", user_id: user.id
      Item.create! happen_at: "2018-06-19T00:00:00+08:00", amount: 200, tags_id: [tag.id], kind: "expenses", user_id: user.id
      get "/api/v1/items/summary", params: {
                                     happened_after: "2018-01-01", happened_before: "2019-01-01",
                                     kind: "expenses", group_by: "happen_at",
                                   }, headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json["groups"].size).to eq 3
      expect(json["groups"][0]["happen_at"]).to eq "2018-06-18"
      expect(json["groups"][0]["amount"]).to eq 300
      expect(json["groups"][1]["happen_at"]).to eq "2018-06-19"
      expect(json["groups"][1]["amount"]).to eq 300
      expect(json["groups"][2]["happen_at"]).to eq "2018-06-20"
      expect(json["groups"][2]["amount"]).to eq 300
      expect(json["total"]).to eq 900
    end
  end
end
