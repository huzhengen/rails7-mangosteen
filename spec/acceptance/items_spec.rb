require "rails_helper"
require "rspec_api_documentation/dsl"

resource "Items" do
  get "/api/v1/items" do
    parameter :page, "page"
    parameter :created_after, "start time"
    parameter :created_before, "end time"
    with_options :scope => :resources do
      response_field :id, "ID"
      response_field :amount, "amount(cent)"
    end
    let(:created_after) { "2022-10-10" }
    let(:created_before) { "2022-11-11" }
    example "Get items" do
      11.times do Item.create amount: 100, created_at: "2022-10-30" end
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resources"].size).to eq 10
    end
  end
end
