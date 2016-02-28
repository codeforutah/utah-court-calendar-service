class WelcomeController < ApplicationController
  before_action :authenticate_developer_account!

  def index
    @api_key = current_developer_account.current_api_key
  end
end
