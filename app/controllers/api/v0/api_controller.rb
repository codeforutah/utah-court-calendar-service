class Api::V0::ApiController < Api::ApiController
  RECOGNIZED_SEARCH_PARAMETERS = ["api_key","case_number","defendant_name", "court_room" , "court_date" , "defendant_otn" , "defendant_dob" , "defendant_so" , "defendant_lea" , "citation_number" ]

  # Search for an event.
  #
  # @param [Hash] params
  # @param [Hash] params [String] api_key The current api key which belongs to the requestor's developer account.
  # @param [Hash] params [String] case_number The court case number.
  # @param [Hash] params [String] defendant_name The defendant name.
  # @param [Hash] params [String] court_room The court room name.
  # @param [Hash] params [String] court_date The court date in YYYY-MM-DD format.
  # @param [Hash] params [String] defendant_otn The defendant offender tracking number.
  # @param [Hash] params [String] defendant_dob The defendant date of burth in YYYY-MM-DD format.
  # @param [Hash] params [String] defendant_so The defendant sheriff number.
  # @param [Hash] params [String] defendant_lea The defendant law enforcement agency number.
  # @param [Hash] params [String] citation_number The citation number.
  #
  # @example
  #
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
  def event_search
    received_at = Time.zone.now
    errors = []
    results = [] # should default to empty
    search_params = params.reject{|k,v| ["controller","format","action"].include?(k) }
    api_key = params["api_key"]
    case_number = params["case_number"].try(:upcase)
    defendant_name = params["defendant_name"].try(:upcase)
    #court_title = params["court_title"]
    court_room = params["court_room"].try(:upcase)
    court_date = params["court_date"] #todo: add error unless in "yyyy-mm-dd" format
    defendant_otn = params["defendant_otn"].try(:upcase)
    defendant_dob = params["defendant_dob"] #todo: add error unless in "yyyy-mm-dd" format
    defendant_so = params["defendant_so"].try(:upcase)
    defendant_lea = params["defendant_lea"].try(:upcase)
    citation_number = params["citation_number"].try(:upcase)

    unrecognized_search_params = search_params.keys - RECOGNIZED_SEARCH_PARAMETERS
    unrecognized_search_params.each do |unrecognized_search_param|
      errors << UnrecognizedEventSearchParameter.new(unrecognized_search_param).message
    end

    if DeveloperAccount.valid_api_keys.include?(api_key)
      results = CourtCalendarEvent.nonproblematic if case_number || defendant_name || court_room || court_date || defendant_otn || defendant_dob || defendant_so || defendant_lea || citation_number
      results = results.where("UPPER(case_number) LIKE ?", "%#{case_number}%") if case_number
      results = results.where("UPPER(defendant) LIKE ?", "%#{defendant_name}%") if defendant_name
      #results = results.where("UPPER(____) LIKE ?", "%#{______}%") if court_title
      results = results.where("UPPER(court_room) LIKE ?", "%#{court_room}%") if court_room
      results = results.where(:date => court_date) if court_date
      results = results.where("UPPER(defendant_offender_tracking_number) LIKE ?", "%#{defendant_otn}%") if defendant_otn
      results = results.where(:defendant_date_of_birth => defendant_dob) if defendant_dob
      results = results.where("UPPER(sheriff_number) LIKE ?", "%#{defendant_so}%") if defendant_so
      results = results.where("UPPER(law_enforcement_agency_number) LIKE ?", "%#{defendant_lea}%") if defendant_lea
      results = results.where("UPPER(citation_number) LIKE ?", "%#{citation_number}%") if citation_number
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
