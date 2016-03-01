class CourtCalendarsController < ApplicationController
  def index
    @court_calendars = CourtCalendar.most_recent
  end
end
