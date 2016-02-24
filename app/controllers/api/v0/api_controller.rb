class Api::V0::ApiController < ApplicationController

  # GET api/v0/event-search.json
  # GET api/v0/event-search.json?case_number=SLC%20161901292
  def event_search
    custom_params = params.reject{|k,v| ["controller","format","action"].include?(k) }

    #eligible_params = []

    @response = {
      :search => {:processed_at => Time.zone.now, :params => custom_params},
      #:errors => [{:code => 0, :message => "No results matched your search. Please try again."}],
      :response => []
    }






    respond_to do |format|
      format.json { render json: @response }
    end
  end
end
