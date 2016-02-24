class Api::V0::ApiController < ApplicationController

  # GET api/v0/event-search.json
  # GET api/v0/event-search.json?case_number=SLC%20161901292
  def event_search
    search_params = params.reject{|k,v| ["controller","format","action"].include?(k) }
    case_number = params["case_number"]

    @response = {
      :request => {:received_at => Time.zone.now, :params => search_params},
    }

    results = []

    if case_number
      results = CourtCalendarEvent.quarantined
      results = results.where(:case_number => case_number)
    end

    results = results.map{|event| event.search_result} if results.any?

    @response.merge!({
      :processed_at => Time.zone.now,
      :results => results,
    })

    respond_to do |format|
      format.json { render json: @response }
    end
  end
end
