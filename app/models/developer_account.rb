class DeveloperAccount < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable #, :omniauthable

  has_many :api_keys, :inverse_of => :developer_account

  after_create :generate_api_key!
  after_destroy :revoke_api_keys!

  def self.valid_api_keys
    joins(:api_keys).merge(ApiKey.unrevoked).pluck(:secret).uniq.compact.sort
  end

  def current_api_key
    api_keys.unrevoked.order(:created_at => :desc).first.secret
  end

  def generate_api_key!
    revoke_api_keys!
    ApiKey.generate!(id)
  end
  alias_method :regenerate_api_key!, :generate_api_key!

  def revoke_api_keys!
    api_keys.unrevoked.each do |unrevoked_api_key|
      unrevoked_api_key.revoke!
    end
  end
end
