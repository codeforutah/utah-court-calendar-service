class ApiKey < ActiveRecord::Base
  belongs_to :developer_account, :inverse_of => :api_keys

  def self.revoked
    where("revoked_at IS NOT NULL")
  end

  def self.unrevoked
    where("revoked_at IS NULL")
  end

  def self.generate!(developer_account_id)
    create!({
      :developer_account_id => developer_account_id,
      :secret => "temporary-#{Time.zone.now.to_datetime.to_s}"
    })
  end

  def revoke!
    update_attributes!(:revoked_at => Time.zone.now)
  end
end
