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

class County < ActiveRecord::Base ; end

class UtahCourt < ActiveRecord::Base
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

class UtahCourtCalendar < ActiveRecord::Base ; end

class UtahCourtCalendarPage < ActiveRecord::Base ; end

class UtahCourtCalendarEvent < ActiveRecord::Base ; end
