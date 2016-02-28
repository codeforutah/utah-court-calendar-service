class ApiKeysController < ApplicationController
  before_action :authenticate_developer_account!

  def show
    @api_key = current_developer_account.current_api_key
    @request_urls = [
      "/api/v0/event-search.json?api_key=#{@api_key}",
      "/api/v0/event-search.json?api_key=#{@api_key}&defendant_name=MARTINEZ",
      "/api/v0/event-search.json?api_key=#{@api_key}&defendant_name=martin",
      "/api/v0/event-search.json?api_key=#{@api_key}&case_number=SLC%20161901292",


      "/api/v0/event-search.json?api_key=#{@api_key}&court_room=W43",
      "/api/v0/event-search.json?api_key=#{@api_key}&court_date=2016-02-25",
      "/api/v0/event-search.json?api_key=#{@api_key}&defendant_otn=43333145",
      "/api/v0/event-search.json?api_key=#{@api_key}&defendant_dob=1988-04-05",
      "/api/v0/event-search.json?api_key=#{@api_key}&defendant_so=368570",
      "/api/v0/event-search.json?api_key=#{@api_key}&defendant_lea=15-165332",
      "/api/v0/event-search.json?api_key=#{@api_key}&citation_number=49090509",




      "/api/v0/event-search.json?api_key=#{@api_key}&court_date=2016-02-25&court_room=W43",
      "/api/v0/event-search.json?api_key=#{@api_key}&case_number=SLC%20161901292&defendant_name=MARTINEZ",
      "/api/v0/event-search.json?api_key=#{@api_key}&case_number=SLC%20161901292&defendant_name=JONES"
    ]
  end

  def regenerate
    current_developer_account.regenerate_api_key!
    redirect_to root_path
  end
end
