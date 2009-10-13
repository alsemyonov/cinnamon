require 'active_support/ordered_hash'

module Cinnamon
  module Navigation
    class Container
      attr_reader :pages

      def initialize
        @pages = PagesArray.new
      end

      def pages=(pages)
        @pages.destroy_all
        @pages << pages
      end

      def to_h
        @pages.to_h
      end

      def notify_order_updated
        @pages.dirty_index = true
      end
    end

  end
end
