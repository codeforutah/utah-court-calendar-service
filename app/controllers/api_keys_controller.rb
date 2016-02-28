class ApiKeysController < ApplicationController
  before_action :authenticate_developer_account!

  def show
    @api_key = current_developer_account.current_api_key
    @request_urls = [
      "/api/v0/event-search.json?api_key=#{@api_key}",
      "/api/v0/event-search.json?api_key=#{@api_key}&defendant_name=MARTINEZ",
      "/api/v0/event-search.json?api_key=#{@api_key}&defendant_name=martin",
      "/api/v0/event-search.json?api_key=#{@api_key}&case_number=SLC%20161901292",
      "/api/v0/event-search.json?api_key=#{@api_key}&case_number=SLC%20161901292&defendant_name=MARTINEZ",
      "/api/v0/event-search.json?api_key=#{@api_key}&case_number=SLC%20161901292&defendant_name=JONES"
    ]
  end

  def regenerate
    current_developer_account.regenerate_api_key!
    redirect_to root_path
  end
end
