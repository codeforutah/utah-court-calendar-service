module UtahCourtsHelper

  UTAH_COURT_CALENDARS_URL = "https://www.utcourts.gov/cal/"
  UTAH_COURT_TYPES = ["DistrictCourt", "JusticeCourt"]

  def self.document
    Nokogiri::HTML(open(UTAH_COURT_CALENDARS_URL))
  end

  # Parse HTML element and persist court attributes.
  #
  # @param [Nokogiri::XML::Element] list_item A nokogiri li element, like li.to_s == "<li><a class=\"icon\" href=\"data/AMERICAN_FORK_Calendar.pdf\">American Fork</a></li>"
  # @param [String] court_type The type of court, expects either "DISTRICT" or "JUSTICE".
  #
  def self.to_court(list_item, court_type)
    raise StandardError.new("INVALID COURT TYPE: '#{court_type}'") unless UTAH_COURT_TYPES.include?(court_type)
    utah_court = UtahCourt.where({
      :type => court_type,
      :name => list_item.text
    }).first_or_create!
    utah_court.update_attributes!({
      :calendar_url => UtahCourtsHelper.to_url(list_item)
    })
    pp utah_court.inspect
  end

  #
  # @param [Nokogiri::XML::Element] list_item A nokogiri li element, like li.to_s == "<li><a class=\"icon\" href=\"data/AMERICAN_FORK_Calendar.pdf\">American Fork</a></li>"
  #
  def self.to_url(list_item)
    suffix = list_item.children.first.attributes["href"].value #> "data/AMERICAN_FORK_Calendar.pdf"
    return "#{UTAH_COURT_CALENDARS_URL}#{suffix}"
  end
end





















module PdfReaderHelper
  ###EVENT_DIVIDER = "------------------------------------------------------------------------------"

  #
  # @param [String] reader_info_date_string A value like "D:20160212021328-07'00'"
  def self.to_datetime(reader_info_date_string)
    date_string = reader_info_date_string.gsub("D:","").gsub("-07'00'","")
    return DateTime.parse(date_string)
  end
end
