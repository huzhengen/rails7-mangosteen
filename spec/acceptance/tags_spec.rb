require "rails_helper"
require "rspec_api_documentation/dsl"

resource "Tags" do
  authentication :basic, :auth
  let(:current_user) { create :user }
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
      create_list :tag, Tag.default_per_page + 1, user: current_user
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resources"].size).to eq Tag.default_per_page
    end
  end

  post "/api/v1/tags" do
    parameter :name, "Name", required: true
    parameter :sign, "Sign", required: true
    parameter :kind, "Kind", required: true, in: ["expenses", "income"]
    with_options :scope => :resources do
      response_field :id, "ID"
      response_field :user_id, "User id"
      response_field :name, "Name"
      response_field :sign, "Sing"
      response_field :kind, "Kind"
      response_field :deleted_time, "Delete time"
    end
    let(:name) { "x" }
    let(:sign) { "y" }
    let(:kind) { "expenses" }
    example "Create a tag" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resource"]["name"]).to eq name
      expect(json["resource"]["sign"]).to eq sign
      expect(json["resource"]["kind"]).to eq kind
    end
  end

  patch "/api/v1/tags/:id" do
    let(:tag) { create :tag, user: current_user }
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
    let(:tag) { create :tag, user: current_user }
    let(:id) { tag.id }
    example "Delete tag" do
      do_request
      expect(status).to eq 200
    end
  end

  get "/api/v1/tags/:id" do
    let(:tag) { create :tag, user: current_user }
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
