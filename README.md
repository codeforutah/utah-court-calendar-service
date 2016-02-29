# Utah Court Calendar Service

## Usage

Visit production application at https://utah-court-calendar-service.herokuapp.com/.

Request data from the API.

### API

The API requires authentication via API key. To obtain an API key:

 1. [Sign-up](https://utah-court-calendar-service.herokuapp.com/developer_accounts/sign_up) for a developer account.
 2. Click on the link in the confirmation email to activate your account.
 3. [Log in](https://utah-court-calendar-service.herokuapp.com/developer_accounts/sign_in) to access your API key.

#### Event Search

Responds with zero or more court calendar events.

`GET /api/v0/event-search.json`

##### Search Parameters

Specify one or more search parameters. A result will be included in the response if it matches ALL request conditions.

event_search_parameter | description | example
--- | --- | ---
`api_key` | The api key which belongs to your developer account. | `123abc456def`
`case_number` | The court case number. | `SLC%20161901292`
`defendant_name` | The defendant name. | `MARTINEZ`
`court_room` | The court room name. | `W43`
`court_date` | The court date in YYYY-MM-DD format. | `2016-02-25`
`defendant_otn` | The defendant offender tracking number. | `43333145`
`defendant_dob` | The defendant date of birth in YYYY-MM-DD format. | `1988-04-05`
`defendant_so` | The defendant sheriff number. | `368570`
`defendant_lea` | The defendant law enforcement agency number. | `15-165332`
`citation_number` | The citation number. | `49090509`

For additional documentation see the [event search method source](/app/controllers/api/v0/api_controller.rb).

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
bundle exec rake extract:courts
bundle exec rake extract:court_calendars
````

## Deploying

From master branch:

```` sh
git push heroku master
````

From another branch:

```` sh
git push heroku mybranch:master
````
