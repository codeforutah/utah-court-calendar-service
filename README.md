# Utah Court Citation Service

## Installation

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
