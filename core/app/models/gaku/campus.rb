module Gaku
  class Campus < ActiveRecord::Base
    include Picture
    include Contacts

    belongs_to :school
    has_one :address, as: :addressable

    validates :name, :school, presence: true

    scope :master, -> { where(master: true) }

    def to_s
      name
    end
  end
end
