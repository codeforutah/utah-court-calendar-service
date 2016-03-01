class CourtCalendarsController < ApplicationController
  def index
    @court_calendars = CourtCalendar.most_recent.order(:page_count => :desc)
  end
end
