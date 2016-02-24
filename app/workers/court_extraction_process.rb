require 'nokogiri'
require 'open-uri'

class CourtExtractionProcess
  COURT_CALENDARS_URL = "https://www.utcourts.gov/cal/"
  COURT_TYPES = ["DistrictCourt", "JusticeCourt"]

  def self.perform
    doc = Nokogiri::HTML(open(COURT_CALENDARS_URL))
    tables = doc.xpath("//table")

    district_courts_table = tables.first
    district_courts = district_courts_table.css("li")
    district_courts.each do |li|
      parse_court(li, "DistrictCourt")
    end

    justice_courts_table = tables.last
    justice_courts = justice_courts_table.css("li")
    justice_courts.each do |li|
      parse_court(li, "JusticeCourt")
    end
  end

  # Parse HTML element and persist court attributes.
  #
  # @param [Nokogiri::XML::Element] list_item A nokogiri li element, like li.to_s == "<li><a class=\"icon\" href=\"data/AMERICAN_FORK_Calendar.pdf\">American Fork</a></li>"
  # @param [String] court_type The type of court, expects either "DISTRICT" or "JUSTICE".
  #
  def self.parse_court(list_item, court_type)
    raise StandardError.new("INVALID COURT TYPE: '#{court_type}'") unless COURT_TYPES.include?(court_type)
    court = Court.where({:type => court_type, :name => list_item.text}).first_or_create!
    court.update_attributes!({:calendar_url => parse_url(list_item)})
    puts court.inspect
    return court
  end

  # Parse HTML element to find court calendar url href value.
  #
  # @param [Nokogiri::XML::Element] list_item A nokogiri li element, like li.to_s == "<li><a class=\"icon\" href=\"data/AMERICAN_FORK_Calendar.pdf\">American Fork</a></li>"
  #
  def self.parse_url(list_item)
    suffix = list_item.children.first.attributes["href"].value #> "data/AMERICAN_FORK_Calendar.pdf"
    return "#{COURT_CALENDARS_URL}#{suffix}"
  end
end
