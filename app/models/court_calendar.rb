class CourtCalendar < ActiveRecord::Base
  belongs_to :court, :inverse_of => :court_calendars
  has_many :pages, :inverse_of => :court_calendar, :class_name => CourtCalendarPage
  has_many :events, :inverse_of => :calendar, :class_name => CourtCalendarEvent

  serialize(:parsing_errors, Array)

  delegate :name, :to => :court, :prefix => true
  delegate :title, :to => :court, :prefix => true
  delegate :type, :to => :court, :prefix => true

  def self.most_recent
    #sql_string =<<-SQL
    #  SELECT
    #    cc.*
    #  FROM (
    #    SELECT
    #      court_id
    #      ,count(DISTINCT id) AS calendar_count
    #      ,max(modified_at) AS last_modified_at
    #    FROM court_calendars
    #    GROUP BY court_id
    #    ORDER BY court_id
    #  ) lcc
    #  JOIN court_calendars cc ON cc.court_id = lcc.court_id AND cc.modified_at = lcc.last_modified_at
    #SQL
    joins("JOIN (
        SELECT
          court_id
          ,count(DISTINCT id) AS calendar_count
          ,max(modified_at) AS last_modified_at
        FROM court_calendars
        GROUP BY court_id
        ORDER BY court_id
      ) lcc ON court_calendars.court_id = lcc.court_id AND court_calendars.modified_at = lcc.last_modified_at
    ")
  end

  def date
    requested_at.to_date
  end

  def inspect
    "#{court.name} #{court.type.titlecase} -- #{url} -- #{page_count}"
  end

  def modified_on
    modified_at.to_date
  end

  def events_count
    events.count
  end

  def expected_events_count
    pages.any? ? pages.map{|page| page.expected_events_count}.compact.sum : 0
  end

  def event_coverage_rate
    expected_events_count == 0 ? 1 : events_count.to_f / expected_events_count
  end
end
