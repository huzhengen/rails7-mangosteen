require "rails_helper"
require "rspec_api_documentation/dsl"

resource "Validation_codes" do
  post "/api/v1/validation_codes" do
    parameter :email, type: :string
    let(:email) { "1@gmail.com" }
    example "Request Code" do
      do_request
      expect(status).to eq 200
      expect(response_body).to eq " "
    end
  end
end
