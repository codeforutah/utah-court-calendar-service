require 'pry'
require 'nokogiri'
require 'open-uri'
require_relative '../app/models.rb'
require_relative '../app/helpers.rb'

include UtahCourtsHelper

doc = UtahCourtsHelper.document

tables = doc.xpath("//table")

district_courts_table = tables.first
district_courts = district_courts_table.css("li")
district_courts.each do |li|
  UtahCourtsHelper.to_court(li, "DistrictCourt")
end

justice_courts_table = tables.last
justice_courts = justice_courts_table.css("li")
justice_courts.each do |li|
  UtahCourtsHelper.to_court(li, "JusticeCourt")
end
