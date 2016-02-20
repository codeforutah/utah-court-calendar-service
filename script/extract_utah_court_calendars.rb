require 'pry'
require 'pdf-reader'
require 'open-uri'
require_relative '../app/models.rb'
require_relative '../app/helpers.rb'

include PdfReaderHelper

UtahCourt.all.each do |court|
  url = court.calendar_url #> "https://www.utcourts.gov/cal/data/AMERICAN_FORK_Calendar.pdf"
  io = open(url, "rb")
  reader = PDF::Reader.new(io)

  #
  # DOCUMENT METADATA
  #

  page_count = reader.page_count

  created_at = PdfReaderHelper.to_datetime(reader.info[:CreationDate])
  modified_at = PdfReaderHelper.to_datetime(reader.info[:ModDate])

  court_calendar = UtahCourtCalendar.where({:utah_court_id => court.id, :url => url, :modified_at => modified_at}).first_or_create!
  court_calendar.update_attributes!({:created_at => created_at, :requested_at => Time.now, :page_count => page_count})

  puts "#{court_calendar.url} -- #{court_calendar.page_count}"

  #
  # DOCUMENT CONTENT
  #

  reader.pages.each do |page|
    page_number = page.number

    begin
      page_content = page.text
    rescue => e
      puts "PAGE #{page_number} -- #{e.class} -- #{e.message}"
      next if e.class == ArgumentError && e.message.include?("Unknown glyph width") # temp workaround for ... https://github.com/OpenSaltLake/utah-court-calendar-service/issues/2
    end

    court_day = Date::DAYNAMES.map{|day| page_content[day]}.compact.first

    begin
      partition = page_content.partition(court_day)
    rescue => e
      puts "PAGE #{page_number} -- #{e.class} -- #{e.message}"
      next if page_content.include?("Nothing to Report") # temp workaround for ... https://github.com/OpenSaltLake/utah-court-calendar-service/issues/3
    end

    #
    # PAGE HEADER CONTENT
    #

    header_content = partition.first
    header_rows = header_content.split("\n") - [""]

    jurisdiction = header_rows.first.strip #> "SECOND DISTRICT-BOUNTIFUL"
    month_name = Date::MONTHNAMES.compact.map{|month| header_rows[1][month] }.compact.first #> "February"
    month_name_index = header_rows[1].index(month_name) #>  64
    judge_name = header_rows[1].slice(0..month_name_index - 1).strip #> "GLEN R DAWSON"
    court_date = header_rows[1].slice(month_name_index.. header_rows[1].length).strip #> "February 22, 2016"
    court_room = header_rows.last.strip #> "COURTROOM 1"

    court_calendar_page = UtahCourtCalendarPage.where({
      :utah_court_calendar_id => court_calendar.id,
      :number => page_number,
      :jurisdiction => jurisdiction,
      :court_day => court_day, # how to handle multiple days per page?
      :court_date => Date.parse(court_date),
      :court_room => court_room,
      :judge_name => judge_name
    }).first_or_create!

    #
    # PAGE BODY CONTENT
    #

=begin

    body_content = partition.last
    body_rows = body_content.split("\n") - [""]

    events_content = page_content.gsub(page_header)

    events = events_content.split(EVENT_DIVIDER)

    events.each do |event|


      court_calendar_event = {
        :utah_court_calendar_id => court_calendar.id,
        :page_number => page_number,
        :jurisdiction => jurisdiction,
        :court_day => court_day,
        :court_date => Date.parse(court_date),
        :court_room => court_room,
        :judge_name => judge_name,

        :session_start_time => "_________",
        :hearing_type => "_________",
        :case_type => "_________",
        :case_number => "_________",
        :citation_number => "_________",
        :sheriff_number => "_________",
        :lea_number => "_________",
        :prosecution => "_________",
        :district_attorneys => "_________",
        :defendants => "_________",
        :defense_attorneys => "_________",
        :flags => "_________",
      }
      puts court_calendar_event

      CourtCalendarEvent.create!(court_calendar_event)
    end

=end

  end
end
