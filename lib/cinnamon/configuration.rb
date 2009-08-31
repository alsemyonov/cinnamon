require 'singleton'

module Cinnamon
  class Configuration
    include Singleton

    attr_accessor :renderer
    attr_accessor :selected_class

    class << self
      def eval_config(context, navigation_context = :default)
        context.instance_eval(Cinnamon.config_files[navigation_context])
        Cinnamon.controller = extract_controller_from(context)
      end

      def run(&block)
        block.call(Configuration.instance)
      end

      def extract_controller_from(context)
        if context.respond_to?(:controller)
          context.controller
        else
          context
        end
      end
    end

    def initialize
      @renderer = Cinnamon::Renderer::List
      @selected_class = 'selected'
    end

    def items(&block)
      @primary_navigation = ItemContainer.new
      block.call(@primary_navigation)
    end

    def loaded?
      !@primary_navigation.nil?
    end
  end
end
