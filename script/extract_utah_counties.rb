require 'csv'
require 'pry'
require 'httparty'

# utah_counties_mock = File.join("../mocks/utah_counties.txt")
# for headers: https://www.census.gov/geo/reference/codes/cou.html
utah_counties_url = "http://www2.census.gov/geo/docs/reference/codes/files/st49_ut_cou.txt"

response = HTTParty.get(utah_counties_url)

CSV.parse(response.body).each do |row|
  # pp row #> ["UT", "49", "001", "Beaver County", "H1"]

  county = {
    :state_postal => row[0],
    :state_fips => row[1],
    :county_fips => row[2],
    :county_name => row[3],
    :fips_class => row[4]
  }
  pp county
end
