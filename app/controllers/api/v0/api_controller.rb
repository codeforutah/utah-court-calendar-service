class Api::V0::ApiController < ApplicationController

  # GET /api/v0/event-search.json
  # GET /api/v0/event-search.json?case_number=SLC%20161901292
  # GET /api/v0/event-search.json?case_number=SLC%20161901292&defendant_name=MARTINEZ
  # GET /api/v0/event-search.json?case_number=SLC%20161901292&defendant_name=JONES
  # GET /api/v0/event-search.json?defendant_name=MALONE
  def event_search
    search_params = params.reject{|k,v| ["controller","format","action"].include?(k) }
    case_number = params["case_number"]
    defendant_name = params["defendant_name"].try(:upcase)

    received_at = Time.zone.now

    results = [] # should default to empty
    results = CourtCalendarEvent.nonproblematic if case_number || defendant_name
    results = results.where(:case_number => case_number) if case_number
    results = results.where("UPPER(defendant) LIKE ?", "%#{defendant_name}%") if defendant_name
    results = results.any? ? results.map{|event| event.search_result} : []

    @response = {
      :request => {
        :url => request.url,
        :params => search_params,
        :received_at => received_at,
        :processed_at => Time.zone.now,
        :results_count => results.count
      },
      :results => results
    }

    respond_to do |format|
      format.json { render json: JSON.pretty_generate(@response) }
    end
  end
end
