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
    no_reportable_events = page_content.scan("Nothing to Report").any?
    if no_reportable_events == true # handles https://github.com/OpenSaltLake/utah-court-calendar-service/issues/3
      starting_date_row = rows.find{|row| row.include?("STARTING:")}
      starting_date_string = starting_date_row.gsub("STARTING:","").split(" - ").first.strip #> "02/17/2016"
      starting_date = Date.strptime(starting_date_string, "%m/%d/%Y")
      ending_date_row = rows.find{|row| row.include?("ENDING:")}
      ending_date_string = ending_date_row.gsub("ENDING:","").split(" - ").first.strip #> "03/16/2016"
      ending_date = Date.strptime(ending_date_string, "%m/%d/%Y")
      judge_row = rows.find{|row| row.include?("JUDGE:")} #> "JUDGE: All"
      judge = judge_row.gsub("JUDGE:","").strip #> "All"
    else
      month = Date::MONTHNAMES.compact.map{|month| rows[1][month] }.compact.first #> "February"
      month_index = rows[1].index(month) #>  64
      court_date_string = rows[1].slice(month_index.. rows[1].length).strip #> "February 22, 2016"
      court_date = Date.strptime(court_date_string, "%B %d, %Y")
      starting_date = court_date
      ending_date = court_date
      judge = rows[1].slice(0..month_index - 1).strip #> "GLEN R DAWSON"
    end
    court_calendar_page_header.update_attributes!({
      :jurisdiction => jurisdiction,
      :judge => judge,
      :start_date => starting_date,
      :end_date => ending_date
    }) # also include court_room and event_count?
    next if no_reportable_events == true

    #
    # PAGE EVENTS
    #

    court_day = Date::DAYNAMES.map{|day| page_content[day]}.compact.first #>  "Monday"
    page_partition = page_content.partition(court_day)
    page_header = page_partition.first
    page_body = page_partition.last

    page_header_rows = page_header.split("\n").map{|row| row.strip }.reject{|row| row == ""}
    court_room = page_header_rows.last #> "COURTROOM 1"

    events = page_body.split(EVENT_DIVIDER)
    events.each do |event|
      rows = event.split("\n").map{|row| row.strip }.reject{|row| row == ""}
      next if rows.empty? # handles pages that have a preceding DIVIDER before the first event. should not count these towards the page.event_count

      event_ids_row = rows.first.split("     ").map{|cell| cell.strip} - [""] # ["08:00 AM", "PRETRIAL CONFERENCE", "BOU 151800323 Other Misdemeanor"] OR ["PRETRIAL CONFERENCE", "BOU 151800323 Other Misdemeanor"]
      @hearing_time = event_ids_row.find{|str| str.include?(" AM") || str.include?(" PM")} || @hearing_time || "OOPS" #> "08:00 AM"
      case_number = event_ids_row.last.split(" ").first(2).join(" ") #> "BOU 151800323"
      case_type = event_ids_row.last.split(" ").last(2).join(" ") #> "Other Misdemeanor"
      if event_ids_row.include?(@hearing_time)
        puts "  + EXPECTING 3 EVENT IDS -- PAGE #{court_calendar_page.number}" unless event_ids_row.count == 3
        hearing_type = event_ids_row[1] #> "PRETRIAL CONFERENCE"
      else
        puts "  + EXPECTING 2 EVENT IDS -- PAGE #{court_calendar_page.number}" unless event_ids_row.count == 2
        hearing_type = event_ids_row[0] #> "PRETRIAL CONFERENCE"
      end

      attorney_rows = rows.select{|row| row.include?("ATTY:") }
      representations = attorney_rows.map{|row| row.split("ATTY:").map{|r| r.strip} }

      defender_ids_row = rows.find{|row| row.include?("OTN:") && row.include?("DOB:")}
      unless defender_ids_row.nil?
        dob_string = defender_ids_row.partition("DOB: ").last.strip #> "02/28/1978"
        begin
          dob = Date.try(:strptime, dob_string, "%m/%d/%Y")
          if dob.year.to_s.length > 4
            dob = nil
            raise
          end
        rescue => e
          puts "  + UNEXPECTED DATE OF BIRTH -- PAGE #{court_calendar_page.number}"
        end
        otn = defender_ids_row.split("DOB: ").first.gsub("OTN:","").strip
        otn = nil if otn == ""
      end

      citation_row = rows.find{|row| row.include?("CITATION #:")}
      case
      when citation_row && citation_row.include?("SHERIFF #:")
        citation_number = citation_row.split("SHERIFF #:").select{|str| str.include?("CITATION #:")}.first.gsub("CITATION #:","").strip
      #when citation_row && citation_row.include?("SHERI>F")
      #  citation_number = citation_row.split("SHERI>F").select{|str| str.include?("CITATION #:")}.first.gsub("CITATION #:","").strip
      #when citation_row && citation_row.include?("S>ERIFF")
      #  citation_number = citation_row.split("S>ERIFF").select{|str| str.include?("CITATION #:")}.first.gsub("CITATION #:","").strip
      when citation_row
        puts "  + UNEXPECTED CITATION CONTENT PAGE #{court_calendar_page.number}"
      end

      so_row = rows.find{|row| row.include?("SHERIFF #:")}
      case
      when so_row && so_row.include?("LEA #:") && so_row.index("LEA #:") > so_row.index("SHERIFF #:")
        so_number = so_row.split("SHERIFF #:").last.split("LEA #:").first.strip
        so_number = nil if so_number == ""
      when so_row
        puts "  + UNEXPECTED S.O. CONTENT PAGE #{court_calendar_page.number}"
      end

      lea_row = rows.find{|row| row.include?("LEA #:")}
      if lea_row
        lea_number = lea_row.partition("LEA #:").last.strip #> "CO2015E10805208 E"
        lea_number = nil if lea_number == ""
      end

      prosecuting_agency_row = rows.find{|row| row.include?("PROSECUTING AGENCY NUMBER:") }
      prosecuting_agency_number = prosecuting_agency_row.gsub("PROSECUTING AGENCY NUMBER: ","").strip unless prosecuting_agency_row.nil?

      case_efiled = true if rows.any?{|row| row.include?("CASE EFILED") }
      case_efiled = false if rows.any?{|row| row.include?("NO CASE EFILED") }

      domestic_violence = rows.any?{|row| row.include?("CASE INVOLVES DOMESTIC VIOLENCE")}

      warrant_outstanding = rows.any?{|row| row.include?("WARRANT OUTSTANDING")}

      small_claims_amount_row = rows.find{|row| row.include?("Amount In Controversy")}
      small_claims_amount = small_claims_amount_row.partition("Amount In Controversy").last.gsub("<","").strip unless small_claims_amount_row.nil?

      court_calendar_event = UtahCourtCalendarEvent.where({
        :utah_court_calendar_id => court_calendar.id,

        :court_room => court_room,
        :date => court_date,
        :time => @hearing_time,

        :hearing_type => hearing_type,
        :case_number => case_number,
        :case_type => case_type,

        :prosecution => representations.first.try(:[], 0),
        :prosecuting_attorney => representations.first.try(:[], 1),
        :prosecuting_agency_number => prosecuting_agency_number,
        :defendant => representations.last.try(:[], 0),
        :defense_attorney => representations.last.try(:[], 1),

        #:defendant_aliases => [], #TODO
        :defendant_offender_tracking_number => otn,
        :defendant_date_of_birth => dob,

        #:charges => [], #TODO
        :citation_number => citation_number,
        :sheriff_number => so_number,
        :law_enforcement_agency_number => lea_number,

        :case_efiled => case_efiled,
        :domestic_violence => domestic_violence,
        :warrant_outstanding => warrant_outstanding,
        :small_claims_amount => small_claims_amount #,

        #:page_numbers => [court_calendar_page.number]
      }).first_or_create!
    end # events.each do |event|




















=begin



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



      #binding.pry if rows.any?{|row| row.include?("AKA ")}
      defendant_aliases = [] #todo

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
