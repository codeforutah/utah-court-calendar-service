class CourtCalendarEvent < ActiveRecord::Base
  belongs_to :calendar, :inverse_of => :events, :class_name => CourtCalendar, :foreign_key => :court_calendar_id

  serialize(:defendant_aliases, Array)
  serialize(:charges, Array)
  serialize(:page_numbers, Array)

  delegate :court_name, :to => :calendar
  delegate :court_title, :to => :calendar
  delegate :court_type, :to => :calendar
  delegate :url, :to => :calendar, :prefix => true
  delegate :modified_on, :to => :calendar, :prefix => true

  def self.nonproblematic
    where("court_room IS NOT NULL")
    .where("prosecuting_attorney NOT LIKE '%[%'")
    .where("defense_attorney NOT LIKE '%[%'")
    .where("case_number NOT LIKE '%ATTY%'")
    .where("defendant != defense_attorney")
    .where("(time LIKE '%AM%' OR time LIKE '%PM%')")
    .where("case_type NOT LIKE '%,%'")
    .where("prosecuting_agency_number NOT LIKE '%CASE EFILED%'")
    .where("prosecuting_agency_number NOT LIKE '%LEA%'")
    .where("length(time) = 8")
  end

  def search_result
    {
      :calendar_url => calendar_url,
      :calendar_modified_on => calendar_modified_on,
      #:calendar_page_count => calendar_page_count,
      #:calendar_page_number => calendar_page_number,
      :court_type => court_type,
      :court_name => court_name,
      :court_title => court_title,
      :court_room => court_room,
      :court_date => date,
      :court_time => time,
      :hearing_type => hearing_type,
      :case_number => case_number,
      :case_type => case_type,
      :prosecution => prosecution,
      :prosecuting_attorney => prosecuting_attorney,
      :prosecuting_agency_number => prosecuting_agency_number,
      :defendant => defendant,
      :defense_attorney => defense_attorney,
      :defendant_offender_tracking_number => defendant_offender_tracking_number,
      :defendant_date_of_birth => defendant_date_of_birth,
      :citation_number => citation_number,
      :sheriff_number => sheriff_number,
      :law_enforcement_agency_number => law_enforcement_agency_number,
      :case_efiled => case_efiled,
      #:domestic_violence => domestic_violence,
      :warrant_outstanding => warrant_outstanding,
      :small_claims_amount => small_claims_amount
    }
  end
end
