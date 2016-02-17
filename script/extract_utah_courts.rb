require 'pry'
require 'nokogiri'
require 'open-uri'
require_relative '../app/models.rb'

UTAH_COURT_CALENDARS_URL = "https://www.utcourts.gov/cal/"
UTAH_COURT_TYPES = ["DistrictCourt", "JusticeCourt"]

# @param [Nokogiri::XML::Element] list_item A nokogiri li element, like li.to_s == "<li><a class=\"icon\" href=\"data/AMERICAN_FORK_Calendar.pdf\">American Fork</a></li>"
def pdf_url(list_item)
  suffix = list_item.children.first.attributes["href"].value #> "data/AMERICAN_FORK_Calendar.pdf"
  return "#{UTAH_COURT_CALENDARS_URL}#{suffix}"
end

# Parse HTML element and persist court attributes.
#
# @param [Nokogiri::XML::Element] list_item A nokogiri li element, like li.to_s == "<li><a class=\"icon\" href=\"data/AMERICAN_FORK_Calendar.pdf\">American Fork</a></li>"
# @param [String] court_type The type of court, expects either "DISTRICT" or "JUSTICE".
#
def parse_court(list_item, court_type)
  raise StandardError.new("INVALID COURT TYPE: '#{court_type}'") unless UTAH_COURT_TYPES.include?(court_type)
  utah_court = UtahCourt.where({
    :type => court_type,
    :name => list_item.text #> "American Fork"
  }).first_or_create!
  utah_court.update_attributes!({
    :calendar_pdf_url => pdf_url(list_item)
  })
  pp utah_court.inspect
end

doc = Nokogiri::HTML(open(UTAH_COURT_CALENDARS_URL))

tables = doc.xpath("//table")

tables.first.css("li").each do |li|
  parse_court(li, "DistrictCourt")
end

tables.last.css("li").each do |li|
  parse_court(li, "JusticeCourt")
end
