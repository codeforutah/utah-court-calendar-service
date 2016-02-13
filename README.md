# Courtbot - SLCo

A courtbot for Salt Lake County.

## APIs

### Rest API

Request json data from [rest api endpoints](/api/reporting/) using the base url: https://raw.githubusercontent.com/s2t2/courtbot-slco/master/api/rest/.

### Reporting API

Request json data from [reporting api endpoints](/api/rest/) using the base url https://raw.githubusercontent.com/s2t2/courtbot-slco/master/api/reporting/.

## Contributing

### Prerequisites

[Install](http://data-creative.info/process-documentation/2015/07/18/how-to-set-up-a-mac-development-environment.html#ruby) ruby and bundler.

[Install](http://data-creative.info/process-documentation/2015/07/18/how-to-set-up-a-mac-development-environment.html#postgresql) postgresql.

### Installation

Download source code and install package dependencies.

```` sh
git clone git@github.com:s2t2/courtbot-slco.git
cd courtbot-slco/
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
````

### Usage

Extract Utah Counties.

```` sh
ruby script/extract_utah_counties.rb
````

Backup database.

```` sh
pg_dump courtbot_slco > ~/Desktop/courtbot_slco.sql
````
