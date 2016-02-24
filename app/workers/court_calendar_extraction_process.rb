require 'pdf-reader'
require 'open-uri'

class CourtCalendarExtractionProcess
  EVENT_DIVIDER = "------------------------------------------------------------------------------"

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

  # @param [String] reader_info_date_string A value like "D:20160212021328-07'00'"
  def self.parse_datetime(reader_info_date_string)
    date_string = reader_info_date_string.gsub("D:","").gsub("-07'00'","")
    return DateTime.parse(date_string)
  end

  def self.perform
    Court.salt_lake.each do |court|
      io = open(court.calendar_url, "rb")
      reader = PDF::Reader.new(io)

      #
      # CALENDAR
      #

      court_calendar = CourtCalendar.where({
        :court_id => court.id,
        :url => court.calendar_url,
        :modified_at => parse_datetime(reader.info[:ModDate])
      }).first_or_create!

      court_calendar.update_attributes!({
        :created_at => parse_datetime(reader.info[:CreationDate]),
        :requested_at => Time.now,
        :page_count => reader.page_count
      })

      puts court_calendar.inspect

      #
      # PAGES
      #

      reader.pages.each do |page|

        #
        # PAGE
        #

        court_calendar_page = CourtCalendarPage.where({
          :court_calendar_id => court_calendar.id,
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
        # HEADER
        #

        court_calendar_page_header = CourtCalendarPageHeader.where({
          :court_calendar_page_id => court_calendar_page.id
        }).first_or_create!

        rows = page_content.split("\n").map{|row| row.strip } - [""]

        no_reportable_events = page_content.scan("Nothing to Report").any?
        if no_reportable_events == true
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
          :jurisdiction => rows.first,
          :judge => judge,
          :start_date => starting_date,
          :end_date => ending_date
        }) # also include court_room and event_count?

        next if no_reportable_events == true

        #
        # EVENTS
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

          ###defendant_aliases = [] #todo
###
          ###charge_date_regex = /\d{2}\/\d{2}\/\d{2}/ #> like "07/05/15"
          ###event_content.scan(charge_date_regex)
###
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

          court_calendar_event = CourtCalendarEvent.where({
            :court_calendar_id => court_calendar.id,

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
        end # each |event|
      end # each |page|
    end # each |court|
  end
end
