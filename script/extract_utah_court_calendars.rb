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
  page_count = reader.page_count
  created_at = PdfReaderHelper.to_datetime(reader.info[:CreationDate])
  modified_at = PdfReaderHelper.to_datetime(reader.info[:ModDate])

  court_cal = UtahCourtCalendar.where({
    :utah_court_id => court.id,
    :url => url,
    :modified_at => modified_at
  }).first_or_create!
  court_cal.update_attributes!({
    :created_at => created_at,
    :requested_at => Time.now,
    :page_count => page_count
  })
  pp court_cal.inspect

  binding.pry

  #
  # PARSE PAGES
  #

  reader.pages.each do |page|
    puts page.fonts #> {:F1=>{:Encoding=>:WinAnsiEncoding, :Subtype=>:Type1, :Type=>:Font, :BaseFont=>:Courier}}
    puts page.text #> this is a mess! ... "                              4TH DISTRICT CT - AF\n\nCHRISTINE JOHNSON                                               February 12, 2016\nCourtrm 1, 3rd Floor                                                       Friday\n\n08:30 AM       REVIEW HEARING                     AME 151100645 Other Misdemeanor\n         AMERICAN FORK CITY                         ATTY: HANSEN, JAMES H\n                                                           MERRILL, TIMOTHY G\n     VS.\n         CASSIDY, DONALD ROSS                       ATTY: PATTEN, KELTON S\n             OTN:             DOB: 07/07/1976\n\n\n         MB - USE OR POSSESSION OF DRUG PARAPHERNALIA       - 06/22/15\n\nCITATION #: A10303012    S>ERIFF NO OTN NUMBER  LEA #< 15AF04789\n                              >     CASE EFILED   <\n  ------------------------------------------------------------------------------\n\n               ORDER TO SHOW CAUSE                AME 151100967 Other Misdemeanor\n         AMERICAN FORK CITY                         ATTY: HANSEN, JAMES H\n     VS.\n         DICKERSON, BROCK                           ATTY: ALLAN, JOHN L\n             OTN: 44301992    DOB: 03/07/1993\n\n         MB - ELECTRONIC COMMUNICATION HARASSMENT           - 09/18/15\n                 >      CASE INVOLVES DOMESTIC VIOLENCE        <\n\nPROSECUTING AGENCY NUMBER: f00278y2015fcn00198\n                              >     CASE EFILED   <\n  ------------------------------------------------------------------------------\n\n               ORDER TO SHOW CAUSE                PLG 131100994 Other Misdemeanor\n         PLEASANT GROVE CITY                        ATTY: PETERSEN, CHRISTINE M\n     VS.\n         DONKOTN: 38495552DLERDOB: 12/19/1992       ATTY:\n\n\n         MA - POSSESS OTHER CONTROLLED SUBSTANCES OR < 1\n               OZ MARIJUANA                                 - 07/20/13\n         MB - UNLAWFUL FOR MINOR TO POSSESS AN ALCOHOLIC\n               PRODUCT                                      - 07/20/13\n\n  ------------------------------------------------------------------------------\n\n         CEDAR HILLS CITYRING                     AMATTY: HANSEN, JAMES Hor DUI\n     VS.\n         DONKERSGOED, CHANDLER OWEN                 ATTY: THAYER, DOUGLAS B\n                                                           WRIGHT, ANDY V\n             OTN: 09978388    DOB: 12/19/1992\n\n\n         MB - IMPAIRED DRIVING                              - 05/19/15\n\nCITATION #: D12534501    SHERIFF #:             LEA #: 15AF03756\n  ------------------------------------------------------------------------------"
    #puts page.raw_content

    #
    # todo: parse the page.
    #

  end
end
