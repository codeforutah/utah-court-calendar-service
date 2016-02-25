# Utah Court Calendar Service

## Usage

Visit production application at https://utah-court-calendar-service.herokuapp.com/.

Request data from the API.

### API

#### Event Search

Responds with one or more events which match ALL search parameters.

`GET /api/v0/event-search.json`

##### Search Parameters

Search for events matching a given case number (e.g. `"SLC 161901292"`).

`GET /api/v0/event-search.json?case_number=SLC%20161901292`

Search for events matching a given defendant name (e.g. `"MARTINEZ"`).

`GET /api/v0/event-search.json?defendant_name=MARTINEZ`

Search for events matching ALL search parameters.

`GET /api/v0/event-search.json?case_number=SLC%20161901292&defendant_name=MARTINEZ`

`GET /api/v0/event-search.json?case_number=SLC%20161901292&defendant_name=JONES`

## Contributing

### Prerequisites

[Install](http://data-creative.info/process-documentation/2015/07/18/how-to-set-up-a-mac-development-environment.html#ruby) ruby and bundler.

[Install](http://data-creative.info/process-documentation/2015/07/18/how-to-set-up-a-mac-development-environment.html#postgresql) postgresql.

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

Create and migrate database.

```` sh
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake db:seed
````

Extract data.

```` sh
#bundle exec rake extract:counties
bundle exec rake extract:courts
bundle exec rake extract:court_calendars
````

## Deploying

```` sh
# from master:
git push heroku master

# from a branch:
git push heroku mybranch:master
````
