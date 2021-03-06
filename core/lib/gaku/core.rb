require 'rails/all'
require 'rails/generators'
require 'rails-i18n'
require 'paperclip'
require 'ransack'
# require 'deface'
require 'redis'

require 'devise'
require 'cancancan'
require 'kaminari'
require 'globalize'
require 'draper'
require 'carmen'

module Gaku
  module Core
  end

  def self.config(&_block)
    yield(Gaku::Config)
  end
end

require 'gaku/core/engine'
require 'gaku/core/console_colors'
require 'generators/gaku/dummy/dummy_generator'
