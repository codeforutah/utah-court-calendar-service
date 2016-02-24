class Court < ActiveRecord::Base
  has_many :court_calendars, :inverse_of => :court

  def self.salt_lake
    where("name LIKE '%Salt Lake%'")
  end

  def title
    "#{name} #{type.titlecase}"
  end
end
class DistrictCourt < Court ; end
class JusticeCourt < Court ; end
