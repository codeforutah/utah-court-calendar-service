class CourtCalendarPage < ActiveRecord::Base
  belongs_to :court_calendar, :inverse_of => :court_calendar_pages
  has_one :court_calendar_page_header, :inverse_of => :court_calendar_page

  def calendar
    court_calendar
  end

  def cal
    court_calendar
  end

  def inspect
    "#{court_calendar.url} -- PAGE #{number}"
  end
end
