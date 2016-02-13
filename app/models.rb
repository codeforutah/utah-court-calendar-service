require 'active_record'
require 'pg'

ActiveRecord::Base.establish_connection(
  adapter:  'postgresql',
  host:     'localhost',
  username: 'courtbot_slco',
  password: 'c0urtb0t!',
  database: 'courtbot_slco',
  encoding: 'unicode',
  pool: 5
) #todo: read from environment-specific config file and set password environment variable in production (standard rails config)

class County < ActiveRecord::Base
end
