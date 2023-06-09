module OddPay::Concerns::IdHashable
  extend ActiveSupport::Concern

  included do
    MIN_HASH_LENGTH = 6
    SALT = Rails.application.secrets.secret_key_base

    def hashid
      self.class.hashids.encode(id)
    end

    def self.find_by_hashid(hashid)
      find_by(id: hashids.decode(hashid))
    end

    def self.find_by_hashid!(hashid)
      find_by!(id: hashids.decode(hashid))
    end

    def self.hashids
      Hashids.new SALT, MIN_HASH_LENGTH
    end
  end
end
