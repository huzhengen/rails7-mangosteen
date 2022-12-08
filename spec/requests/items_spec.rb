require "rails_helper"

RSpec.describe "Items", type: :request do
  describe "Get items" do
    it "pagination" do
      11.times do
        Item.create! amount: 100
      end
      expect(Item.count).to eq(11)
      get "/api/v1/items"
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 10
      get "/api/v1/items?page=2"
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 1
    end
    it "filter by time" do
      item1 = Item.create amount: 100, created_at: "2018-01-02"
      item2 = Item.create amount: 100, created_at: "2018-01-02"
      item3 = Item.create amount: 100, created_at: "2019-01-01"
      get "/api/v1/items?created_after=2018-01-01&created_before=2018-01-03"
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 2
      expect(json["resources"][0]["id"]).to eq item1.id
      expect(json["resources"][1]["id"]).to eq item2.id
    end
    it "filter by time(boundary conditions)" do
      item1 = Item.create amount: 100, created_at: "2018-01-01"
      get "/api/v1/items?created_after=2018-01-01&created_before=2018-01-02"
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json["resources"].size).to eq 1
      expect(json["resources"][0]["id"]).to eq item1.id
    end
  end

  describe "create" do
    it "can create an item" do
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
