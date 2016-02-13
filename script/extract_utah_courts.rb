require 'pry'
require 'nokogiri'
require 'open-uri'
require_relative '../app/models.rb'

utah_court_calendars_url = "https://www.utcourts.gov/cal/"

doc = Nokogiri::HTML(open(utah_court_calendars_url))

tables = doc.xpath("//table")

# expect there to be only two tables: district courts, and justice courts

# parse district courts

tables.first.css("li").each do |li|
  utah_court = {
    :type => "DISTRICT",
    :name => li.text, #> "American Fork"
    :calendar_pdf_link => li.children.first.attributes["href"].value #> "data/AMERICAN_FORK_Calendar.pdf"
  }
  pp utah_court
end

# parse justice courts

tables.last.css("li").each do |li|
  utah_court = {
    :type => "JUSTICE",
    :name => li.text, #> "Alpine"
    :calendar_pdf_link => li.children.first.attributes["href"].value #> "data/Just_HIGHLAND_2501_Calendar.pdf"
  }
  pp utah_court
end
