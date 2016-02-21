require 'pry'
require 'pdf-reader'
require 'open-uri'
require_relative '../app/models.rb'
require_relative '../app/helpers.rb'

include PdfReaderHelper

UtahCourt.extractable.each do |court|
  io = open(court.calendar_url, "rb")
  reader = PDF::Reader.new(io)

  #
  # CALENDAR PDF
  #

  court_calendar = UtahCourtCalendar.where({
    :utah_court_id => court.id,
    :url => court.calendar_url,
    :modified_at => PdfReaderHelper.to_datetime(reader.info[:ModDate])
  }).first_or_create!

  court_calendar.update_attributes!({
    :created_at => PdfReaderHelper.to_datetime(reader.info[:CreationDate]),
    :requested_at => Time.now,
    :page_count => reader.page_count
  })

  puts court_calendar.inspect

  reader.pages.each do |page|

    #
    # PAGE
    #

    court_calendar_page = UtahCourtCalendarPage.where({
      :utah_court_calendar_id => court_calendar.id,
      :number => page.number,
    }).first_or_create!
    begin
      page_content = page.text
      court_calendar_page.update_attributes!({:parsable => true})
    rescue => e # e.class == ArgumentError && e.message.include?("Unknown glyph width")
      puts "  + UNPARSABLE PAGE #{court_calendar_page.number} -- #{e.class} -- #{e.message}"
      court_calendar_page.update_attributes!({:parsable => false, :parsing_errors => ["#{e.class} -- #{e.message}"]})
      next
    end

    #
    # PAGE HEADER
    #

    court_calendar_page_header = UtahCourtCalendarPageHeader.where({
      :utah_court_calendar_page_id => court_calendar_page.id
    }).first_or_create!
    rows = page_content.split("\n").map{|row| row.strip } - [""]
    jurisdiction = rows.first
    if page_content.scan("Nothing to Report: ").any?
      binding.pry
      calendar_start_date = Date.parse("2014-01-01")
      calendar_end_date = Date.parse("2014-12-25")
      court_date_range = (calendar_start_date..calendar_end_date)
      court_dates = court_date_range.to_a
      judge = "ALL"
    else
      month = Date::MONTHNAMES.compact.map{|month| rows[1][month] }.compact.first #> "February"
      month_index = rows[1].index(month) #>  64
      court_date_string = rows[1].slice(month_index.. rows[1].length).strip #> "February 22, 2016"
      court_date = Date.strptime(court_date_string, "%B %d, %Y")
      court_dates = [court_date.to_s]
      judge = rows[1].slice(0..month_index - 1).strip #> "GLEN R DAWSON"
    end
    court_calendar_page_header.update_attributes!({
      :jurisdiction => jurisdiction,
      :judge => judge,
      :court_dates => court_dates
    })

    #
    # PAGE EVENTS
    #










































    #binding.pry
=begin
    court_calendar_page.update_attributes({:events_count => })
    court_calendar_page.update_attributes({:parsable => parsable})

    next unless court_calendar_page.parsable?



    court_day = Date::DAYNAMES.map{|day| page_content[day]}.compact.first

    begin
      partition = page_content.partition(court_day)
    rescue => e
      puts "PAGE #{page_number} -- #{e.class} -- #{e.message}"
      next if page_content.include?("Nothing to Report") # temp workaround for ... https://github.com/OpenSaltLake/utah-court-calendar-service/issues/3
    end

    header_content = partition.first
    header_rows = header_content.split("\n") - [""]
    jurisdiction = header_rows.first.strip #> "SECOND DISTRICT-BOUNTIFUL"
    month_name = Date::MONTHNAMES.compact.map{|month| header_rows[1][month] }.compact.first #> "February"
    month_name_index = header_rows[1].index(month_name) #>  64
    judge_name = header_rows[1].slice(0..month_name_index - 1).strip #> "GLEN R DAWSON"
    court_date_string = header_rows[1].slice(month_name_index.. header_rows[1].length).strip #> "February 22, 2016"
    court_date = Date.strptime(court_date_string, "%B %d, %Y")
    court_room = header_rows.last.strip #> "COURTROOM 1"

    court_calendar_page = UtahCourtCalendarPage.where({
      :utah_court_calendar_id => court_calendar.id,
      :number => page_number,
      :jurisdiction => jurisdiction,
      :court_day => court_day, # how to handle multiple days per page?
      :court_date => court_date,
      :court_room => court_room,
      :judge_name => judge_name
    }).first_or_create!

























    #
    # PAGE BODY CONTENT
    #

    next unless court.name.include?("Salt Lake County")

    body_content = partition.last #> "\n\n08:30 AM       PRETRIAL CONFERENCE                S18 151601829 Other Misdemeanor\n         STATE OF UTAH                              ATTY:\n     VS.\n         AVILA, FLORENCIO ELVIS                     ATTY: FOWLER, AMY N\n             OTN:             DOB: 02/28/1978\n\n\n         MB - RETAIL THEFT (SHOPLIFTING)                    - 12/12/15\n\nCITATION #: E10805208    SHERIFF #:             LEA #: CO2015E10805208 E\n                          >   >  NO CASE EFILED   <  <\n  ------------------------------------------------------------------------------\n\n               PRETRIAL CONFERENCE                S18 151601686 Other Misdemeanor\n         STATE OF UTAH                              ATTY:\n     VS.\n         BEE, CHRISTOPHER ALLEN                     ATTY: FOWLER, AMY N\n             OTN: 49028467    DOB: 12/02/1983\n\n\n         IN - DISORDERLY CONDUCT                            - 10/13/15\n\nCITATION #: E10799580    SHERIFF #:             LEA #: CO2015E10799580 E\n                              >     CASE EFILED   <\n  ------------------------------------------------------------------------------\n\n               *********                          S18 031601507 Other Misdemeanor\n         *********, *********                       ATTY:\n     VS.\n         *********, *********                       ATTY: CORUM, PATRICK W\n                 >      CASE INVOLVES DOMESTIC VIOLENCE        <\n\nCITATION #: J5533062     SHERIFF #:             LEA #:\n                          >      NO OTN NUMBER       <\n  ------------------------------------------------------------------------------\n\n               *********                          S18 051602452 Other Misdemeanor\n         *********, *********                       ATTY:\n     VS.\n         *********, *********                       ATTY: SMITH, GREGORY B\n\nCITATION #:              SHERIFF #:             LEA #:\n                          >      NO OTN NUMBER       <\n  ------------------------------------------------------------------------------\n\n               BENCH WARRANT                      U00 155601786 Misdemeanor DUI\n         STATE OF UTAH                              ATTY:\n     VS.\n         CHRISTENSEN, SHADEAU SCOTT                 ATTY:\n             OTN: 48832117    DOB: 09/29/1993\n\n         MB - IMPAIRED DRIVING                              - 05/02/15\n\nCITATION #: D122824774   SHERIFF #:             LEA #: 15SL02833\n                              >     CASE EFILED   <\n                          >   WARRANT OUTSTANDING    <\n                          >        FTA ISSUED        <\n  ------------------------------------------------------------------------------"
    events_content = body_content.gsub(header_content,"") #> "\n\n08:30 AM       PRETRIAL CONFERENCE                S18 151601829 Other Misdemeanor\n         STATE OF UTAH                              ATTY:\n     VS.\n         AVILA, FLORENCIO ELVIS                     ATTY: FOWLER, AMY N\n             OTN:             DOB: 02/28/1978\n\n\n         MB - RETAIL THEFT (SHOPLIFTING)                    - 12/12/15\n\nCITATION #: E10805208    SHERIFF #:             LEA #: CO2015E10805208 E\n                          >   >  NO CASE EFILED   <  <\n  ------------------------------------------------------------------------------\n\n               PRETRIAL CONFERENCE                S18 151601686 Other Misdemeanor\n         STATE OF UTAH                              ATTY:\n     VS.\n         BEE, CHRISTOPHER ALLEN                     ATTY: FOWLER, AMY N\n             OTN: 49028467    DOB: 12/02/1983\n\n\n         IN - DISORDERLY CONDUCT                            - 10/13/15\n\nCITATION #: E10799580    SHERIFF #:             LEA #: CO2015E10799580 E\n                              >     CASE EFILED   <\n  ------------------------------------------------------------------------------\n\n               *********                          S18 031601507 Other Misdemeanor\n         *********, *********                       ATTY:\n     VS.\n         *********, *********                       ATTY: CORUM, PATRICK W\n                 >      CASE INVOLVES DOMESTIC VIOLENCE        <\n\nCITATION #: J5533062     SHERIFF #:             LEA #:\n                          >      NO OTN NUMBER       <\n  ------------------------------------------------------------------------------\n\n               *********                          S18 051602452 Other Misdemeanor\n         *********, *********                       ATTY:\n     VS.\n         *********, *********                       ATTY: SMITH, GREGORY B\n\nCITATION #:              SHERIFF #:             LEA #:\n                          >      NO OTN NUMBER       <\n  ------------------------------------------------------------------------------\n\n               BENCH WARRANT                      U00 155601786 Misdemeanor DUI\n         STATE OF UTAH                              ATTY:\n     VS.\n         CHRISTENSEN, SHADEAU SCOTT                 ATTY:\n             OTN: 48832117    DOB: 09/29/1993\n\n         MB - IMPAIRED DRIVING                              - 05/02/15\n\nCITATION #: D122824774   SHERIFF #:             LEA #: 15SL02833\n                              >     CASE EFILED   <\n                          >   WARRANT OUTSTANDING    <\n                          >        FTA ISSUED        <\n  ------------------------------------------------------------------------------"
    #session_start_time_index = events_content.index(" AM ") || events_content.index(" PM ")
    events = events_content.split(EVENT_DIVIDER)
    events.each do |event_content| #> "\n\n08:30 AM       PRETRIAL CONFERENCE                S18 151601829 Other Misdemeanor\n         STATE OF UTAH                              ATTY:\n     VS.\n         AVILA, FLORENCIO ELVIS                     ATTY: FOWLER, AMY N\n             OTN:             DOB: 02/28/1978\n\n\n         MB - RETAIL THEFT (SHOPLIFTING)                    - 12/12/15\n\nCITATION #: E10805208    SHERIFF #:             LEA #: CO2015E10805208 E\n                          >   >  NO CASE EFILED   <  <\n  "
      rows = event_content.split("\n").map{|row| row.strip }.reject{|row| row == ""}

      next if rows.empty?

      #
      # EVENT HEADER ROW
      #

      event_header_row = rows.first #> "08:00 AM       PRETRIAL CONFERENCE                BOU 151800323 Other Misdemeanor"
      header_cells = event_header_row.split("     ").map{|cell| cell.strip} - [""]

      @hearing_time = header_cells.find{|str| str.include?(" AM") || str.include?(" PM")} || @hearing_time || "OOPS" #> "08:00 AM"

      if header_cells.include?(@hearing_time) && (header_cells.include?("SMALL CLAIMS") || event_header_row.include?("Small Claim"))
        hearing_type = header_cells[1] #> "SMALL CLAIMS"
        case_number = header_cells.last.split(" ").first #> "158601073"
        case_type = header_cells.last.split(" ").last(2).join(" ") #> "Small Claim"
      elsif header_cells.include?(@hearing_time)
        hearing_type = header_cells[1] #> "PRETRIAL CONFERENCE"
        case_number = header_cells.last.split(" ").first(2).join(" ") #> "BOU 151800323"
        case_type = header_cells.last.split(" ").last(2).join(" ") #> "Other Misdemeanor"
      elsif header_cells.include?("*********")
        hearing_type = header_cells.first #> "*********"
        case_number = header_cells.last.split(" ").first(2).join(" ") #> "S18 031601507"
        case_type = header_cells.last.split(" ").last(2).join(" ") #> "Other Misdemeanor"
      elsif header_cells.include?("SMALL CLAIMS")
        hearing_type = header_cells.first #> "SMALL CLAIMS"
        case_number = header_cells.last.split(" ").first #> "158601096"
        case_type = header_cells.last.split(" ").last(2).join(" ") #> "Small Claim"
      elsif event_header_row.include?("ATTY:")
        next #todo: handle
      elsif event_header_row.include?("Small") #|| case_type.include?("Misdemeanor")
        hearing_type = header_cells.first #> "SUPPLEMENTAL ORDER"
        case_number = header_cells.last.split(" ").first #> "158600100"
        case_type = header_cells.last.split(" ").last(2).join(" ") #> "Small Claim"
      else
        hearing_type = header_cells.first #> "PRETRIAL CONFERENCE"
        case_number = header_cells.last.split(" ").first(2).join(" ") #> "S18 151601686"
        case_type = header_cells.last.split(" ").last(2).join(" ") #> "Other Misdemeanor"
      end # this is terrible

      ###binding.pry if case_number.try(:include?, "Small") || case_number.try(:include?, "ORDER TO")

      #
      # ATTORNEY ROWS
      #

      attorney_rows = rows.select{|row| row.include?("ATTY:") }
      representations = attorney_rows.map{|row| row.split("ATTY:").map{|r| r.strip} }
      prosecution, prosecutor_name = representations.first[0], representations.first[1]
      defendant_full_name, defense_attorney_name = representations.last[0], representations.last[1]

      #
      # DEFENDENT ALIAS ROWS
      #

      #binding.pry if rows.any?{|row| row.include?("AKA ")}
      defendant_aliases = [] #todo

      #
      # DEFENDENT IDENTIFICATION ROW
      #

      ids_row = rows.find{|row| row.include?("OTN: ") && row.include?("DOB: ")}
      unless ids_row.nil?
        offender_tracking_number = offender_tracking_number = ids_row.split("DOB: ").first.gsub("OTN:","").strip
        offender_tracking_number = nil if offender_tracking_number == ""
        date_string_of_birth = ids_row.split("DOB: ").last.strip #> "02/28/1978"
        date_of_birth = Date.strptime(date_string_of_birth, "%m/%d/%Y")
        #date_of_birth_regex = /\d{2}\/\d{2}\/\d{4}/ #> like "06/19/1994"
      end

      #
      # CITATION IDENTIFICATION ROW
      #

      citation_row = rows.find{|row| row.include?("CITATION #:") && row.include?("SHERIFF #:") && row.include?("LEA #:")} #> "CITATION #:              SHERIFF #:             LEA #: 2015-002957"
      unless citation_row.nil?
        citation_number = citation_row.split("SHERIFF #:").first.gsub("CITATION #:","").strip #> "E10805208"
        citation_number = nil if citation_number == ""
        sheriff_number = citation_row.split("SHERIFF #:").last.split("LEA #:").first.strip
        sheriff_number = nil if sheriff_number == ""
        lea_number = citation_row.partition("LEA #:").last.strip #> "CO2015E10805208 E"
        lea_number = nil if lea_number == ""
      else
        # malformatted
        citation_row = rows.find{|row| row.include?("CITATION #:") && row.include?("SHERI>F #:") && row.include?("LE< #:")} #> "CITATION #: E10798943    SHERI>F #: CASE EFILED LE< #: CO2015E10798943 E"
        unless citation_row.nil?
          citation_number = citation_row.split("SHERI>F #:").first.gsub("CITATION #:","").strip #> "E10798943"
          citation_number = nil if citation_number == ""
          sheriff_number = citation_row.split("SHERI>F #:").last.split("LE< #:").first.strip #> "CASE EFILED"
          sheriff_number = nil if sheriff_number == "" || sheriff_number == "CASE EFILED"
          lea_number = citation_row.partition("LE< #:").last.strip #> "CO2015E10798943 E"
          lea_number = nil if lea_number == ""
        else
          # partially-detected
          citation_row = rows.find{|row| row.include?("LEA #:")} #> "CITATION #: E10798943    SHERI>F #: CASE EFILED LE< #: CO2015E10798943 E"
          unless citation_row.nil?
            lea_number = citation_row.partition("LEA #:").last.strip #> "CO2015E10805208 E"
            lea_number = nil if lea_number == ""
          else
            # binding.pry unless hearing_type == "SMALL CLAIMS" || case_type == "Small Claim"

            # must find a better solution this code is bad
            citation_row = rows.find{|row| row.include?("CITATION #:")}
            citation_number = citation_row.gsub("CITATION #:","").strip.split(" ").first if citation_row

          end
        end
      end

















      #
      # CHARGES SECTION
      #


      charge_date_regex = /\d{2}\/\d{2}\/\d{2}/ #> like "07/05/15"
      event_content.scan(charge_date_regex)

      ###charge_rows = rows.select{|row|
      ###  PdfReaderHelper.charge_abbreviation_matchers.map{|matcher|
      ###    row.include?(matcher)
      ###  }.include?(true)
      ###} #> ["MB - THEFT                                         - 08/08/15", "MB - RETAIL THEFT (SHOPLIFTING)                    - 12/12/15"]
      ###charges = charge_rows.map{|charge_row|
      ###  court_date_string = charge_row.split("-").last.strip #> "08/08/15"
###
      ###  begin
      ###    court_date = Date.strptime(court_date_string, "%m/%d/%Y")
      ###  rescue => e
      ###    puts "#{e.class} -- #{e.message} -- #{court_date_string}"
      ###    court_date = court_date_string #todo: handle multiline charges
      ###  end
###
      ###  charge = {
      ###    :level => charge_row.split("-").first.strip, #> "MB"
      ###    :code => charge_row.split("-")[1].strip, #> "THEFT"
      ###    :date =>  court_date
      ###  }
      ###}

      #
      # PROSECUTING AGENCY IDENTIFICATION ROW
      #

      prosecuting_agency_row = rows.find{|row| row.include?("PROSECUTING AGENCY NUMBER:") }
      prosecuting_agency_number = prosecuting_agency_row.gsub("PROSECUTING AGENCY NUMBER: ","").strip unless prosecuting_agency_row.nil?

      #
      # MESSAGE ROWS
      #

      case_efiled = true if rows.any?{|row| row.include?("CASE EFILED") }
      case_efiled = false if rows.any?{|row| row.include?("NO CASE EFILED") }

      domestic_violence = rows.any?{|row| row.include?("CASE INVOLVES DOMESTIC VIOLENCE")}

      warrant_outstanding = rows.any?{|row| row.include?("WARRANT OUTSTANDING")}

      small_claims_amount_row = rows.find{|row| row.include?("Amount In Controversy")}
      small_claims_amount = small_claims_amount_row.partition("Amount In Controversy").last.gsub("<","").strip unless small_claims_amount_row.nil?

      #
      #
      #

      upcoming_hearing = {
        :type => hearing_type,
        :day => court_day,
        :date => court_date,
        :time => @hearing_time,
        :court => {
          :type => court.type,
          :name => court.name,
          :lat => court.lat,
          :lon => court.lon,
          :arrival_instructions => court.arrival_instructions,
          :room => court_room
        },
        :judge => judge_name,
        :prosecution => {
          :name => prosecution,
          :agency_number => prosecuting_agency_number,
        },
        :prosecutor => prosecutor_name,
        :defense => defense_attorney_name,
        :defendant => {
          :full_name => defendant_full_name,
          :date_of_birth => date_of_birth,
          :offender_tracking_number => offender_tracking_number,
          :aliases => defendant_aliases,
          :warrant_outstanding => warrant_outstanding
        },
        :case => {
          :type => case_type,
          :jurisdiction => jurisdiction,
          :number => case_number,
          :efiled => case_efiled,
          :citation_number => citation_number,
          :sheriff_number => sheriff_number,
          :lea_number => lea_number,
          :charges => charges,
          :domestic_violence => domestic_violence,
          :small_claims_amount => small_claims_amount
        },
        :sources => [
          {
            :calendar_url => court_calendar.url,
            :page_numbers => [page_number]
          }
        ]
      }

      pp upcoming_hearing #[:case][:number]
    end









=end
  end # reader.pages.each
end # UtahCourt.all.each
