# Utah Court Citation Service

## Usage

Visit production application at https://utah-court-calendar-service.herokuapp.com/.

Request data from the API.

### API

#### Event Search

Responds with one or more events which match the search parameters.

##### Endpoint

`GET /api/v0/event-search.json`

##### Parameters

Search for events matching a given case number (e.g. `"SLC 161901292"`).

`GET /api/v0/event-search.json?case_number=SLC%20161901292`


## Contributing

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
````

Extract data.

```` sh
bundle exec rake extract:counties
bundle exec rake extract:courts
#bundle exec rake extract:court_calendars
````
