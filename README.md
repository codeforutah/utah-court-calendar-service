# Utah Court Calendar Service

## APIs

### [Rest API](/api/rest/)

  + /courts.json

### [Reporting API](/api/reporting/)

  + /upcoming-hearings.json



## Contributing

### Prerequisites

[Install](http://data-creative.info/process-documentation/2015/07/18/how-to-set-up-a-mac-development-environment.html#ruby) ruby and bundler.

[Install](http://data-creative.info/process-documentation/2015/07/18/how-to-set-up-a-mac-development-environment.html#postgresql) postgresql.

### Installation

Download source code and install package dependencies.

```` sh
git clone git@github.com:OpenSaltLake/utah-court-calendar-service.git
cd utah-court-calendar-service/
bundle install
````

Create database user.

```` sh
psql
CREATE USER courtbot_slco WITH ENCRYPTED PASSWORD 'c0urtb0t!';
ALTER USER courtbot_slco CREATEDB;
ALTER USER courtbot_slco WITH SUPERUSER;
\q
````

Create database.

```` sh
psql -U courtbot_slco --password -d postgres -f $(pwd)/db/create.sql
````

Migrate database.

```` sh
ruby db/migrate/create_counties.rb
ruby db/migrate/create_utah_courts.rb
ruby db/migrate/create_utah_court_calendars.rb
````

## Usage

Extract, transform, and load data.

```` sh
ruby script/extract_utah_counties.rb
ruby script/extract_utah_courts.rb
ruby script/extract_utah_court_calendars.rb
````

Backup database.

```` sh
pg_dump courtbot_slco > ~/Desktop/courtbot_slco.sql
````
