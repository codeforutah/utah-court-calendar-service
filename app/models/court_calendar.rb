class CourtCalendar < ActiveRecord::Base
  belongs_to :court, :inverse_of => :court_calendars
  has_many :court_calendar_pages, :inverse_of => :court_calendar
  has_many :events, :inverse_of => :calendar, :class_name => CourtCalendarEvent

  serialize(:parsing_errors, Array)

  delegate :name, :to => :court, :prefix => true
  delegate :title, :to => :court, :prefix => true
  delegate :type, :to => :court, :prefix => true

  def date
    requested_at.to_date
  end

  def inspect
    "#{court.name} #{court.type.titlecase} -- #{url} -- #{page_count}"
  end

  def modified_on
    modified_at.to_date
  end
end
