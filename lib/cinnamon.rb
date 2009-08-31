require 'active_support'

module Cinnamon
  mattr_accessor :config_files
  mattr_accessor :config_file_path
  mattr_accessor :controller
  self.config_files = {}

  class << self
    def load_config(navigation_context = :default)
      raise 'config_file_path is not set!' unless self.config_file_path
      raise "Config file #{config_file_name(navigation_context)} does not exists!" unless File.exists?(config_file_name(navigation_context))
      if ::RAILS_ENV == 'production'
        self.config_files[navigation_context] ||= IO.read(config_file_name(navigation_context))
      else
        self.config_files[navigation_context] = IO.read(config_file_name(navigation_context))
      end
    end

    def config
      Configuration.instance
    end

    def primaty_navigation
      config.primaty_navigation
    end

    def config_file_name(navigation_context = :default)
      file_name = navigation_context == :default ? '' : "#{navigation_context.to_s.underscore}_"
      File.join(config_file_path, "#{file_name}navigation.rb")
    end
  end
end
