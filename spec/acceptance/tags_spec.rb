require "rails_helper"
require "rspec_api_documentation/dsl"

resource "Tags" do
  authentication :basic, :auth
  let(:current_user) { User.create email: "1@gmail.com" }
  let(:auth) { "Bearer #{current_user.generate_jwt}" }
  get "/api/v1/tags" do
    parameter :page, "Page"
    parameter :kind, "Kind", in: ["expenses", "income"]
    with_options :scope => :resources do
      response_field :id, "ID"
      response_field :user_id, "User id"
      response_field :name, "Name"
      response_field :sign, "Sing"
      response_field :deleted_time, "Delete time"
    end
    example "Get tags" do
      11.times do |i|
        Tag.create name: "tag#{i}", sign: "x", kind: "expenses", user_id: current_user.id
      end
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resources"].size).to eq 10
    end
  end

  post "/api/v1/tags" do
    parameter :name, "Name", required: true
    parameter :sign, "Sign", required: true
    with_options :scope => :resources do
      response_field :id, "ID"
      response_field :user_id, "User id"
      response_field :name, "Name"
      response_field :sign, "Sing"
      response_field :deleted_time, "Delete time"
    end
    let(:name) { "x" }
    let(:sign) { "y" }
    example "Create a tag" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resource"]["name"]).to eq name
      expect(json["resource"]["sign"]).to eq sign
    end
  end

  patch "/api/v1/tags/:id" do
    let(:tag) { Tag.create! name: "name", sign: "sign", user_id: current_user.id }
    let(:id) { tag.id }
    parameter :name, "Name"
    parameter :sign, "Sign"
    with_options :scope => :resources do
      response_field :id, "ID"
      response_field :user_id, "User id"
      response_field :name, "Name"
      response_field :sign, "Sing"
      response_field :deleted_time, "Delete time"
    end
    let(:name) { "x" }
    let(:sign) { "y" }
    example "Update a tag" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resource"]["name"]).to eq name
      expect(json["resource"]["sign"]).to eq sign
    end
  end

  delete "/api/v1/tags/:id" do
    let(:tag) { Tag.create name: "x", sign: "x", user_id: current_user.id }
    let(:id) { tag.id }
    example "Delete tag" do
      do_request
      expect(status).to eq 200
    end
  end

  get "/api/v1/tags/:id" do
    let(:tag) { Tag.create name: "x", sign: "x", user_id: current_user.id }
    let(:id) { tag.id }
    with_options :scope => :resources do
      response_field :id, "ID"
      response_field :user_id, "User id"
      response_field :name, "Name"
      response_field :sign, "Sing"
      response_field :deleted_time, "Delete time"
    end
    example "Get one tag" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resource"]["id"]).to eq tag.id
    end
  end
end
