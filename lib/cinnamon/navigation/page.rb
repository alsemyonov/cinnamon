module Cinnamon
  module Navigation
    class Page < Container
      attr_accessor :label, :id, :title,
        :class, :target, :rel, :rev,
        :order, :active, :visible, :parent,
        :properties

      def self.factory(options = {})
        new(options)
      end

      def initialize(options = nil)
        super
        @active = false
        @visible = true
        @rel = {}
        @rev = {}
        @properties = {}

        self.options = options
      end

      def options=(opts)
        opts.each do |key, value|
          self.send("#{key}=", value)
        end
      end

      def method_missing(method, *args)
        if method.ends_with?('=')
          @properties[method.gsub(/=$/, '')] = args.first
        else
          @properties[method]
        end
      end

      def label=(label)
        unless label.nil? || label.is_a?(String)
          raise Exception, 'label must be a string or nil'
        end

        @label = label
      end

      def id=(id)
        unless id.nil? || id.is_a?(String) || id.is_a?(Numeric)
          raise Exception, 'id must be a string, numeric or nil'
        end

        @id = id.nil? ? id : id.to_s
      end

      def klass=(klass)
        unless klass.nil? || klass.is_a?(String)
          raise Exception, 'class must be a string or nil'
        end

        @klass = klass
      end

      def title=(title)
        unless title.nil? || title.is_a?(String)
          raise Exception, 'title must be a non-empty string'
        end

        @title = title
      end

      def target=(target)
        unless target.nil? || target.is_a?(String)
          raise Exception, 'target must be a string or nil'
        end

        @target = target
      end

      def rel=(rel)
        unless rel.nil?
          raise Exception, 'relations must be a hash' unless rel.is_a?(Hash)

          rel.each do |name, relation|
            @rel[name] = relation
          end
        end
      end

      def rev=(rev)
        unless rev.nil?
          raise Exception, 'reverse relations must be a hash' unless rev.is_a?(Hash)

          rev.each do |name, relations|
            @rev[name] = relations
          end
        end
      end

      def order=(order)
        if order.is_a?(String)
          temp = order.to_i
          if temp < 0 || temp > 0 || order == '0'
            order = temp
          end
        end

        unless order.nil? || order.is_a?(Numeric)
          raise Exception, 'order must be an integer or nil, or a string that casts to an integer'
        end

        @order = order

        if parent?
          parent.notify_order_updated
        end
      end

      # TODO add after rolelogic added
      # def resource=(resource)
      # end

      # def privilege=(privilege)
      # end

      def active=(active)
        @active = !!active
      end

      def active?(recursive = false)
        if !@active && recursive
          pages.each do |page|
            return true if page.active?(true)
          end
          return false
        end
        @active
      end
      alias_method :active, :active?

      def active(recursive = false)
        active?(recursive)
      end

      def visible=(visible)
        @visible = !!visible
      end

      def visible?(recursive = false)
        if !@visible && recursive
          pages.each do |page|
            return true if page.visible?(true)
          end
          return false
        end
        @visible
      end
      alias_method :visible, :visible?

      def parent=(parent)
        if parent == self
          raise Exception, 'A page cannot have itself as a parent'
        end

        unless parent == @parent
          unless @parent.nil?
            @parent.remove_page(self)
          end

          @parent = parent

          unless @parent.nil? || @parent.has_page?(self, false)
            @parent.add_page(self)
          end
        end
      end

      def to_s
        label
      end

      def defined_rel
        @rel.keys
      end

      def defined_rev
        @rev.keys
      end

      def hash_code
        self.object_id
      end
    end
  end
end
