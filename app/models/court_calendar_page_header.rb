class CourtCalendarPageHeader < ActiveRecord::Base
  belongs_to :court_calendar_page, :inverse_of => :court_calendar_page_header
end
