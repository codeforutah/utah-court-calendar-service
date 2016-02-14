require 'pry'
require 'pdf-reader'
require 'open-uri'
#require 'active_support/all'
require_relative '../app/models.rb'

UtahCourt.all.each do |court|
  pdf_url = court.calendar_pdf_url #> "https://www.utcourts.gov/cal/data/AMERICAN_FORK_Calendar.pdf"

  io = open(pdf_url, "rb")

  reader = PDF::Reader.new(io)

  #puts reader.info #> {:CreationDate=>"D:20160212021328-07'00'", :ModDate=>"D:20160212021328-07'00'", :Producer=>"itext-paulo-155 (itextpdf.sf.net-lowagie.com)"}

  creation_date_string = reader.info[:CreationDate].gsub("D:","").gsub("-07'00'","")
  file_created_at = DateTime.parse(creation_date_string)

  modification_date_string = reader.info[:ModDate].gsub("D:","").gsub("-07'00'","")
  file_modified_at = DateTime.parse(creation_date_string)

  court_cal = UtahCourtCalendar.where({
    :utah_court_id => court.id,
    :court_date => Date.today,
    :pdf_url => pdf_url
  }).first_or_create!
  court_cal.update_attributes!({
    :pdf_created_at => file_created_at,
    :pdf_modified_at => file_modified_at,
    :page_count => reader.page_count
  })

  pp court_cal.inspect
end
