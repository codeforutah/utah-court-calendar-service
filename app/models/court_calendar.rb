class CourtCalendar < ActiveRecord::Base
  belongs_to :court, :inverse_of => :court_calendars
  has_many :court_calendar_pages, :inverse_of => :court_calendar
  has_many :court_calendar_events, :inverse_of => :court_calendar

  serialize(:parsing_errors, Array)

  def date
    requested_at.to_date
  end

  def inspect
    "#{court.name} #{court.type.titlecase} -- #{url} -- #{page_count}"
  end

  def pages
    court_calendar_pages
  end

  def events
    court_calendar_events
  end
end
