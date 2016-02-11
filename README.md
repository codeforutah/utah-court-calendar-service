# courtbot-slco

a courtbot for salt lake county.

## Usage

Request mock data from https://raw.githubusercontent.com/s2t2/courtbot-slco/master/mocks/upcoming_hearings.json.

## Contributing

Generate timestamps in a javascript console:

```` js
var hearing_starts_at = new Date('2016-03-10T08:00:00')
hearing_starts_at.getTime() //> 1457596800000
````
