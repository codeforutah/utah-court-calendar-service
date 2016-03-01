class ApiKey < ActiveRecord::Base
  belongs_to :developer_account, :inverse_of => :api_keys

  def self.revoked
    where("revoked_at IS NOT NULL")
  end

  def self.unrevoked
    where("revoked_at IS NULL")
  end

  # @param [String] key_secret
  def self.find_by_secret(key_secret)
    where(:secret => key_secret).first
  end

  def self.generate!(developer_account_id)
    create!({
      :developer_account_id => developer_account_id,
      :secret => SecureRandom.urlsafe_base64
    })
  end

  def unrevoked?
    revoked_at.nil?
  end

  def revoke!
    update_attributes!(:revoked_at => Time.zone.now)
  end
end
