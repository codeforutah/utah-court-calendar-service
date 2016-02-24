require 'csv'
require 'httparty'

class CountyExtractionProcess
  # for headers: https://www.census.gov/geo/reference/codes/cou.html
  # utah_counties_mock = File.join("../mocks/utah_counties.txt")
  UTAH_COUNTIES_URL = "http://www2.census.gov/geo/docs/reference/codes/files/st49_ut_cou.txt"

  def self.perform
    response = HTTParty.get(UTAH_COUNTIES_URL)

    CSV.parse(response.body).each do |row| #> ["UT", "49", "001", "Beaver County", "H1"]
      county = County.where({
        :state_postal => row[0],
        :state_fips => row[1],
        :county_fips => row[2],
        :county_name => row[3],
      }).first_or_create!
      county.update_attributes!({
        :fips_class => row[4]
      })

      puts county
    end
  end
end
