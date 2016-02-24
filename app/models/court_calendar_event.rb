class CourtCalendarEvent < ActiveRecord::Base
  belongs_to :court_calendar, :inverse_of => :court_calendar_events

  serialize(:defendant_aliases, Array)
  serialize(:charges, Array)
  serialize(:page_numbers, Array)
end
