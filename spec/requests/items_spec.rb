require "rails_helper"

RSpec.describe "Items", type: :request do
  describe "Get items" do
    it "not logged in" do
      user1 = User.create! email: "1@gmail.com"
      11.times do
        Item.create! amount: 100, user_id: user1.id
      end
      get "/api/v1/items"
      expect(response).to have_http_status(401)
    end
    it "pagination" do
      user1 = User.create! email: "1@gmail.com"
      user2 = User.create! email: "2@gmail.com"
      11.times do
        Item.create! amount: 100, user_id: user1.id
      end
      11.times do
        Item.create! amount: 100, user_id: user2.id
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
      item1 = Item.create amount: 100, created_at: "2018-01-02", user_id: user1.id
      item2 = Item.create amount: 100, created_at: "2018-01-02", user_id: user1.id
      item3 = Item.create amount: 100, created_at: "2019-01-01", user_id: user1.id
      get "/api/v1/items?created_after=2018-01-01&created_before=2018-01-03", headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 2
      expect(json["resources"][0]["id"]).to eq item1.id
      expect(json["resources"][1]["id"]).to eq item2.id
    end
    it "filter by time(boundary conditions)" do
      user1 = User.create! email: "1@gmail.com"
      item1 = Item.create amount: 100, created_at: "2018-01-01", user_id: user1.id
      get "/api/v1/items?created_after=2018-01-01&created_before=2018-01-02", headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 1
      expect(json["resources"][0]["id"]).to eq item1.id
    end
    it "filter by time(boundary conditions 2)" do
      user1 = User.create! email: "1@gmail.com"
      item1 = Item.create amount: 100, created_at: "2018-01-01", user_id: user1.id
      item2 = Item.create amount: 100, created_at: "2017-01-01", user_id: user1.id
      get "/api/v1/items?created_after=2018-01-01", headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 1
      expect(json["resources"][0]["id"]).to eq item1.id
    end
    it "filter by time(boundary conditions 3)" do
      user1 = User.create! email: "1@gmail.com"
      item1 = Item.create amount: 100, created_at: "2018-01-01", user_id: user1.id
      item2 = Item.create amount: 100, created_at: "2019-01-01", user_id: user1.id
      get "/api/v1/items?created_before=2018-01-02", headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 1
      expect(json["resources"][0]["id"]).to eq item1.id
    end
  end

  describe "create" do
    xit "can create an item" do
      expect {
        post "/api/v1/items", params: { amount: 99 }
      }.to change { Item.count }.by 1
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json["resource"]["id"]).to be_an Numeric
      expect(json["resource"]["amount"]).to eq 99
    end
  end
end
