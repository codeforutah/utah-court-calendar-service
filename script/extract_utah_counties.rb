require 'csv'
require 'pry'
require 'httparty'
#require_relative "../app/models.rb"

#utah_counties_mock = File.join("../mocks/utah_counties.txt")
utah_counties_url = "http://www2.census.gov/geo/docs/reference/codes/files/st49_ut_cou.txt"

response = HTTParty.get(utah_counties_url)

puts response.code

pp response.body
