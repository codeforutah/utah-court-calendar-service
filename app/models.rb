require 'active_record'
require 'pg'

ActiveRecord::Base.establish_connection(
  adapter:  'postgresql',
  host:     'localhost',
  username: 'courtbot_slco',
  password: 'c0urtb0t!',
  database: 'utah_courts',
  encoding: 'unicode',
  pool: 5
) #todo: read from environment-specific config file and set password environment variable in production (standard rails config)

class County < ActiveRecord::Base
end

class UtahCourt < ActiveRecord::Base
  has_many :utah_court_calendars, :inverse_of => :utah_court

  def self.salt_lake
    where("name LIKE '%Salt Lake%'")
  end

  def self.extractable
    all # salt_lake
  end

  def lat
   "todo"
  end

  def lon
   "todo"
  end

  def arrival_instructions
   "todo"
  end
end
class DistrictCourt < UtahCourt ; end
class JusticeCourt < UtahCourt ; end

class UtahCourtCalendar < ActiveRecord::Base
  belongs_to :utah_court, :inverse_of => :utah_court_calendars
  has_many :utah_court_calendar_pages, :inverse_of => :utah_court_calendar

  serialize(:parsing_errors, Array)

  def date
    requested_at.to_date
  end

  def inspect
    "#{utah_court.name} #{utah_court.type.titlecase} -- #{url} -- #{page_count}"
  end
end

class UtahCourtCalendarPage < ActiveRecord::Base
  belongs_to :utah_court_calendar, :inverse_of => :utah_court_calendar_pages
  has_one :utah_court_calendar_page_header, :inverse_of => :utah_court_calendar_page

  #def parsable?
  #  parsable
  #end
end

class UtahCourtCalendarPageHeader < ActiveRecord::Base
  belongs_to :utah_court_calendar_page, :inverse_of => :utah_court_calendar_page_header
  serialize(:court_dates, Array)
end

class UtahCourtCalendarEvent < ActiveRecord::Base
end
