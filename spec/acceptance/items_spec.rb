require "rails_helper"
require "rspec_api_documentation/dsl"

resource "Items" do
  authentication :basic, :auth
  let(:current_user) { User.create email: "1@gmail.com" }
  let(:auth) { "Bearer #{current_user.generate_jwt}" }
  get "/api/v1/items" do
    parameter :page, "page"
    parameter :created_after, "start time"
    parameter :created_before, "end time"
    with_options :scope => :resources do
      response_field :id, "ID"
      response_field :amount, "Amount(cent)"
      response_field :tags_id, "Tag ids"
      response_field :happen_at, "Happen time"
      response_field :kind, "Kind"
    end
    let(:created_after) { Time.now - 10.days }
    let(:created_before) { Time.now + 10.days }
    example "Get items" do
      tag1 = Tag.create! name: "name", sign: "sign", user_id: current_user.id
      tag2 = Tag.create! name: "name", sign: "sign", user_id: current_user.id
      11.times do
        Item.create amount: 100, tags_id: [tag1.id, tag2.id], happen_at: Time.now, user_id: current_user.id
      end
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resources"].size).to eq 10
    end
  end

  post "/api/v1/items" do
    parameter :amount, "Amount", required: true
    parameter :tags_id, "Tag ids", required: true
    parameter :happen_at, "Happen time", required: true
    parameter :kind, "Kind", required: true, emum: ["expenses", "income"]
    with_options :scope => :resources do
      response_field :id, "ID"
      response_field :amount, "Amount(cent)"
      response_field :tags_id, "Tag ids"
      response_field :happen_at, "Happen time"
      response_field :kind, "Kind"
    end
    let(:amount) { 100 }
    let(:happen_at) { "2018-01-01T00:00:00+08:00" }
    let(:kind) { "expenses" }
    let(:tags) { (0..1).map { Tag.create! name: "name", sign: "sign", user_id: current_user.id } }
    let(:tags_id) { tags.map(&:id) }
    example "Create an item" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resource"]["amount"]).to eq amount
      expect(json["resource"]["user_id"]).to eq current_user.id
    end
  end

  get "/api/v1/items/summary" do
    parameter :happened_after, "Start time", required: true
    parameter :happened_before, "End time", required: true
    parameter :kind, "Kind", enum: ["expenses", "income"], required: true
    parameter :group_by, "happen_at", enum: ["happen_at", "tag_id"], required: true
    response_field :groups, "Group"
    response_field :total, "Total"
    let(:happened_after) { "2018-01-01" }
    let(:happened_before) { "2019-01-01" }
    let(:kind) { "expenses" }
    example "Get items summary by happen_at" do
      user = current_user
      tag = Tag.create! name: "tag1", sign: "x", user_id: user.id
      Item.create! amount: 100, kind: "expenses", tags_id: [tag.id], happen_at: "2018-06-18T00:00:00+08:00", user_id: user.id
      Item.create! amount: 200, kind: "expenses", tags_id: [tag.id], happen_at: "2018-06-18T00:00:00+08:00", user_id: user.id
      Item.create! amount: 100, kind: "expenses", tags_id: [tag.id], happen_at: "2018-06-20T00:00:00+08:00", user_id: user.id
      Item.create! amount: 200, kind: "expenses", tags_id: [tag.id], happen_at: "2018-06-20T00:00:00+08:00", user_id: user.id
      Item.create! amount: 100, kind: "expenses", tags_id: [tag.id], happen_at: "2018-06-19T00:00:00+08:00", user_id: user.id
      Item.create! amount: 200, kind: "expenses", tags_id: [tag.id], happen_at: "2018-06-19T00:00:00+08:00", user_id: user.id
      do_request group_by: "happen_at"
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["groups"].size).to eq 3
      expect(json["groups"][0]["happen_at"]).to eq "2018-06-18"
      expect(json["groups"][0]["amount"]).to eq 300
      expect(json["groups"][1]["happen_at"]).to eq "2018-06-19"
      expect(json["groups"][1]["amount"]).to eq 300
      expect(json["groups"][2]["happen_at"]).to eq "2018-06-20"
      expect(json["groups"][2]["amount"]).to eq 300
      expect(json["total"]).to eq 900
    end

    example "Get items summary by tag_id" do
      user = current_user
      tag1 = Tag.create! name: "tag1", sign: "x", user_id: user.id
      tag2 = Tag.create! name: "tag2", sign: "x", user_id: user.id
      tag3 = Tag.create! name: "tag3", sign: "x", user_id: user.id
      Item.create! amount: 100, kind: "expenses", tags_id: [tag1.id, tag2.id], happen_at: "2018-06-18T00:00:00+08:00", user_id: user.id
      Item.create! amount: 200, kind: "expenses", tags_id: [tag2.id, tag3.id], happen_at: "2018-06-18T00:00:00+08:00", user_id: user.id
      Item.create! amount: 300, kind: "expenses", tags_id: [tag3.id, tag1.id], happen_at: "2018-06-18T00:00:00+08:00", user_id: user.id
      do_request group_by: "tag_id"
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["groups"].size).to eq 3
      expect(json["groups"][0]["tag_id"]).to eq tag3.id
      expect(json["groups"][0]["amount"]).to eq 500
      expect(json["groups"][1]["tag_id"]).to eq tag1.id
      expect(json["groups"][1]["amount"]).to eq 400
      expect(json["groups"][2]["tag_id"]).to eq tag2.id
      expect(json["groups"][2]["amount"]).to eq 300
      expect(json["total"]).to eq 600
    end
  end
end
