require "rails_helper"
require "rspec_api_documentation/dsl"

resource "Tags" do
  get "/api/v1/tags" do
    authentication :basic, :auth
    parameter :page, "Page"
    with_options :scope => :resources do
      response_field :id, "ID"
      response_field :user_id, "User id"
      response_field :name, "Name"
      response_field :sign, "Sing"
      response_field :deleted_time, "Delete time"
    end
    let(:current_user) { User.create email: "1@gmail.com" }
    let(:auth) { "Bearer #{current_user.generate_jwt}" }
    example "Get tags" do
      11.times do |i|
        Tag.create name: "tag#{i}", sign: "x", user_id: current_user.id
      end
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resources"].size).to eq 10
    end
  end
end
