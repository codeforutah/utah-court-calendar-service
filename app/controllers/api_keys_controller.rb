class ApiKeysController < ApplicationController
  before_action :authenticate_developer_account!

  def regenerate
    current_developer_account.regenerate_api_key
    redirect_to root_path
  end
end
