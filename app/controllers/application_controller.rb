class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  after_action :log_request

private

  def log_request
    Request.create!({
      :developer_account_id => current_developer_account.try(:id),
      :session_id => session["session_id"],
      :uuid => request.try(:uuid),
      :language => request.try(:accept_language),
      :ip_address => request.try(:remote_ip),
      :user_agent => request.try(:user_agent),
      :url => request.try(:url),
      :referrer => request.try(:referrer),
      :ssl => request.try(:ssl?)
    })
  end
end
