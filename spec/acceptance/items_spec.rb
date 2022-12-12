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
end
