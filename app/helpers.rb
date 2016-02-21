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
  EVENT_DIVIDER = "------------------------------------------------------------------------------"

  CASE_TYPES = [
    "State Felony",
    "Misdemeanor DUI",
    "Other Misdemeanor",
    "Small Claim"
  ]

  HEARING_TYPES = [
    "INITIAL APPEARANCE",
    "ARRAIGNMENT ARR",
    "SUMMONS ARRAIGNMENT",

    "BENCH WARRANT HRG",
    "BENCH WARRANT/OSC HEARING",
    "BENCH WARRANT/OSC",
    "BENCH WARRANT/ OSC",
    "BENCH WARRANT HRG/SCHED CONF",
    "SCHEDULING CONFERENCE 1",

    "DISPOSITION",
    "DISPOSITION HEARING",

    "REVIEW HEARING",

    "BW/COMPLETE JAIL TIME",
    "BENCH WARRANT/SENTENCING",
    "SENTENCING",

    "SMALL CLAIMS"
  ] # these are starting to look dirty

  CHARGE_TYPES = [
    {:name => "Felony - Level 1",       :abbreviation => "F1", :description => "____________",},
    {:name => "Felony - Level 2",       :abbreviation => "F2", :description => "____________",},
    {:name => "Felony - Level 3",       :abbreviation => "F3", :description => "____________",},
    {:name => "Misdemeanor - Level A",  :abbreviation => "MA", :description => "____________",},
    {:name => "Misdemeanor - Level B",  :abbreviation => "MB", :description => "____________",},
    {:name => "Misdemeanor - Level C",  :abbreviation => "MC", :description => "____________",},
    {:name => "Infraction",             :abbreviation => "IN", :description => "____________",},
  ]

  def self.charge_abbreviations
    CHARGE_TYPES.map{|ct| ct[:abbreviation] }
  end

  def self.charge_abbreviation_matchers
    charge_abbreviations.map{|ca| "#{ca} - "}
  end






  #
  # @param [String] reader_info_date_string A value like "D:20160212021328-07'00'"
  def self.to_datetime(reader_info_date_string)
    date_string = reader_info_date_string.gsub("D:","").gsub("-07'00'","")
    return DateTime.parse(date_string)
  end
end
