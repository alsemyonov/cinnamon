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

    class PagesArray < ::Array
      attr_accessor :dirty_order
      @dirty_index = false

      def add(page)
        case page
        when self
          raise Exception, 'A page cannot have itself as a parent'
        when Array, Page
          page = Page.factory(page)
        else
          raise Exception, 'page must be an instance of Cinnamon::Navigation::Page or array'
        end

        unless include?(page)
          self << page
        end
      end

      def <<(pages)
        pages.each do |page|
          add_page(page)
        end
      end

      def remove(page)
        case page
        when Page
          if (result = delete(page))
            @dirty_order = true
          end
          return page
        when Numeric
          sort_by_order!
          if result = delete_at(page)
            @dirty_order = true
          end
          return result
        end
        false
      end

      def remove_all
        replace(PagesArray.new)
      end

      def any?(page = nil, recursive = false)
        if page.nil?
          return !length.zero?
        else
          if include?(page)
            return true
          elsif recursive
            each do |child|
              if child.pages.any?(page, true)
                return true
              end
            end
          end
        end
        false
      end

      def first(conditions = nil)
        if conditions.blank? || conditions.length > 1
          raise Exception, 'conditions must be a pair :property => value'
        end

        property = conditions.keys.first
        value = conditions.values.first
        detect do |page|
          page.send(property) == value
        end
      end

      def all(conditions = nil)
        if conditions.blank? || conditions.length > 1
          raise Exception, 'conditions must be a pair :property => value'
        end

        property = conditions.keys.first
        value = conditions.values.first
        find_all do |page|
          page.send(property) == value
        end
      end

      def find(how_many, conditions)
        if how_many = :first
          first(conditions)
        else
          all(conditions)
        end
      end

      def method_missing(method, *args)
        case method
        when /(find(?:_one|_all)?_by_)(.*)/
          send($1, $2 => args.first)
        else
          super
        end
      end

    protected
      def sort_by_order!
        sort! do |a, b|
          a.order <=> b.order
        end
      end
    end
  end
end
