class Api::V0::ApiController < Api::ApiController
  RECOGNIZED_SEARCH_PARAMETERS = ["api_key","case_number","defendant_name"]

  # GET /api/v0/event-search.json
  # GET /api/v0/event-search.json?case_number=SLC%20161901292
  # GET /api/v0/event-search.json?case_number=SLC%20161901292&defendant_name=MARTINEZ
  # GET /api/v0/event-search.json?case_number=SLC%20161901292&defendant_name=JONES
  # GET /api/v0/event-search.json?defendant_name=MARTINEZ
  def event_search
    received_at = Time.zone.now
    errors = []
    results = [] # should default to empty
    search_params = params.reject{|k,v| ["controller","format","action"].include?(k) }
    api_key = params["api_key"]
    case_number = params["case_number"]
    defendant_name = params["defendant_name"].try(:upcase)

    unrecognized_search_params = search_params.keys - RECOGNIZED_SEARCH_PARAMETERS
    unrecognized_search_params.each do |unrecognized_search_param|
      errors << UnrecognizedEventSearchParameter.new(unrecognized_search_param).message
    end

    if DeveloperAccount.valid_api_keys.include?(api_key)
      results = CourtCalendarEvent.nonproblematic if case_number || defendant_name
      results = results.where(:case_number => case_number) if case_number
      results = results.where("defendant LIKE ?", "%#{defendant_name}%") if defendant_name
    elsif api_key
      errors << InvalidApiKeyError.new(api_key).message
    else
      errors << MissingApiKeyError.new.message
    end

    results = results.any? ? results.map{|event| event.search_result} : [] # should reset to empty array instead of nil value or activerecord object

    @response = {
      :request => {:url => request.url, :params => search_params, :received_at => received_at},
      :processed_at => Time.zone.now,
      :errors => errors,
      :results_count => results.count,
      :results => results
    }

    respond_to do |format|
      format.json { render json: JSON.pretty_generate(@response) }
    end
  end

  class UnrecognizedEventSearchParameter < ApiError
    def initialize(search_param)
      class_name = self.class.name.gsub("Api::V0::ApiController::","")
      msg = "#{class_name} -- '#{search_param}'"
      super(msg)
    end
  end
end
