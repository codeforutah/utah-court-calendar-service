require 'rails_helper'

RSpec.describe Api::V0::ApiController, type: :controller do
  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:developer_account]
    dev_account = FactoryGirl.create(:developer_account)
    dev_account.confirm
    sign_in dev_account
  end

  let(:recognized_key_secret){controller.current_developer_account.current_api_key}

  context "when request does not contain an api key" do
    let(:response){
      rsp = get :event_search, {"format"=>"json"}
      JSON.parse(rsp.body)
    }

    it "should return MissingApiKeyError" do
      matching_error_messages = response["errors"].select{|str| str.include?("MissingApiKeyError")}
      expect(matching_error_messages).to_not be_empty
    end

    it "should not return any results" do
      expect(response["results"]).to be_empty
    end
  end

  context "when request contains an unrecognized api key" do
    let(:unrecognized_key_secret){"idksomething"}
    let(:response){
      rsp = get :event_search, {"format"=>"json", "api_key"=> unrecognized_key_secret}
      JSON.parse(rsp.body)
    }

    it "should return UnrecognizedApiKeyError" do
      matching_error_messages = response["errors"].select{|str| str.include?("UnrecognizedApiKeyError")}
      expect(matching_error_messages).to_not be_empty
    end

    it "should not return any results" do
      expect(response["results"]).to be_empty
    end
  end

  context "when request contains a recognized, unrevoked api key" do
    let(:response){
      rsp = get :event_search, {"format"=>"json", "api_key"=>recognized_key_secret}
      JSON.parse(rsp.body)
    }

    it "should not return MissingApiKeyError nor UnrecognizedApiKeyError" do
      matching_error_messages = response["errors"].select{|str| str.include?("MissingApiKeyError") || str.include?("UnrecognizedApiKeyError")}
      expect(matching_error_messages).to be_empty
    end
  end

  context "when request contains an unrecognized search parameter" do
    let(:response){
      rsp = get :event_search, {
        "format"=>"json",
        "api_key"=>recognized_key_secret,
        "def_name"=>"MARTINEZ"
      }
      JSON.parse(rsp.body)
    }

    it "should return UnrecognizedEventSearchParameter" do
      matching_error_messages = response["errors"].select{|str| str.include?("UnrecognizedEventSearchParameter")}
      expect(matching_error_messages).to_not be_empty
    end

    it "should not return any results" do
      expect(response["results"]).to be_empty
    end
  end

  #todo: test each of the following example searches:

  # GET /api/v0/event-search.json
  # GET /api/v0/event-search.json?case_number=SLC%20161901292
  # GET /api/v0/event-search.json?case_number=SLC%20161901292&defendant_name=MARTINEZ
  # GET /api/v0/event-search.json?case_number=SLC%20161901292&defendant_name=JONES
  # GET /api/v0/event-search.json?defendant_name=MARTINEZ
  # GET /api/v0/event-search.json?api_key=123abc456def
  # GET /api/v0/event-search.json?api_key=123abc456def&defendant_name=MARTINEZ
  # GET /api/v0/event-search.json?api_key=123abc456def&defendant_name=martin
  # GET /api/v0/event-search.json?api_key=123abc456def&case_number=SLC%20161901292
  # GET /api/v0/event-search.json?api_key=123abc456def&court_room=W43
  # GET /api/v0/event-search.json?api_key=123abc456def&court_date=2016-02-25
  # GET /api/v0/event-search.json?api_key=123abc456def&defendant_otn=43333145
  # GET /api/v0/event-search.json?api_key=123abc456def&defendant_dob=1988-04-05
  # GET /api/v0/event-search.json?api_key=123abc456def&defendant_so=368570
  # GET /api/v0/event-search.json?api_key=123abc456def&defendant_lea=15-165332
  # GET /api/v0/event-search.json?api_key=123abc456def&citation_number=49090509
  # GET /api/v0/event-search.json?api_key=123abc456def&court_date=2016-02-25&court_room=W43
  # GET /api/v0/event-search.json?api_key=123abc456def&case_number=SLC%20161901292&defendant_name=MARTINEZ
  # GET /api/v0/event-search.json?api_key=123abc456def&case_number=SLC%20161901292&defendant_name=JONES
end
