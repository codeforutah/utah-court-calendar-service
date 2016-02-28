require 'rails_helper'

RSpec.describe Api::ApiController, type: :controller do
  # http://localhost:3000/api/v0/event-search.json
  # context: api requests which do not contain a api_key url parameter
  # response should be empty
  # error messages should contain "MissingApiKeyError"

  # http://localhost:3000/api/v0/event-search.json?api_key=INVALIDSTRING
  # context: api requests which contain an invalid api_key url parameter
  # response should be empty
  # error messages should contain "InvalidApiKeyError -- INVALIDSTRING"

  # http://localhost:3000/api/v0/event-search.json?api_key=test_key
  # context: api requests which contain a valid api_key url parameter
  # error messages should not contain "InvalidApiKeyError" or "MissingApiKeyError"
  # error messages should be empty
  let(:valid_api_keys){ ["test_key"] }

  # http://localhost:3000/api/v0/event-search.json?api_key=test_key&def_name=MARTINEZ
  # context: api requests which contain an unexpected search parameter (e.g. "def_name")
  # response should be empty
  # error messages should contain "UnrecognizedEventSearchParameter -- def_name"
end
