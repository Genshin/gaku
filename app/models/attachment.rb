class Attachment < ActiveRecord::Base
	
	attr_accessible :name, :description, :asset

	belongs_to :attachable, :polymorphic => true

	has_attached_file :asset

	validates :name, :presence => true

	default_scope :conditions => { :is_deleted => false }

end