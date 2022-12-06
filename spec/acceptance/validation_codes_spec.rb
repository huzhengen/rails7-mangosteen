require "rails_helper"
require "rspec_api_documentation/dsl"

resource "Validation_codes" do
  post "/api/v1/validation_codes" do
    example "Request code" do
      do_request

      expect(status).to eq 400
    end
  end
end
