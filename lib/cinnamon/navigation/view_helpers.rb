module Cinnamon
  module Navigation
    module ViewHelpers
      @@navigation_options = {
        :renderer => 'Cinnamon::Navigation::NavigationRenderer'
      }
      mattr_reader :navigation_options

      def menu(container = nil, options = {})
        options.symbolize_keys!.reverse_merge!(Cinnamon::Navigation::ViewHelpers.navigation_options)
        navigation_helper(container, options)
      end

      def links
        # TODO: links helper
      end

      def breadcrumbs
        # TODO: breadcrumbs helper
      end

      def sitemap
        # TODO: sitemap helper
      end

    protected
      def navigation_helper(container, options)
        renderer = options.delete(:renderer) {}
        renderer = case options[:renderer]
                   when String
                     options[:renderer].to_s.constantize.new
                   when Class
                     options[:renderer].new
                   else
                     options[:renderer]
                   end

        renderer.prepare(container, options, self)
        renderer.to_html
      end
    end

  end

  class Renderer
    attr_accessor :container,
      :min_depth, :max_depth,
      :indent, :render_invisible

    def prepare(container, options, template)
      @container = container
      @template = template
      @options.each do |property, value|
        send("#{property}=", value)
      end
    end

    def container
      if @container.nil?
        nav = cinnamon.navigation_container
        if nav
          return @container = nav
        end

        @container = Cinnamon::Navigation::Base.new
      end

      @container
    end

    def min_depth=(depth)
      if depth.nil? || depth.is_a?(Numeric)
        @min_depth = depth
      else
        @min_depth = depth.to_i
      end
    end

    def min_depth
      if !@min_depth.is_a?(Numeric) || @min_depth < 0
        return 0
      end
      @min_depth
    end

    def max_depth=(depth)
      if depth.nil? || depth.is_a?(Numeric)
        @max_depth = depth
      else
        @max_depth = depth.to_i
      end
    end

    def indent=(indent)
      @indent = whitespace(indent)
    end

    def render_invisible=(render_invisible)
      @render_invisible = !!render_invisible
    end

    def find_active(container, min_depth = nil, max_depth = -1)
      min_depth = self.min_depth unless min_depth.is_a?(Numeric)
      max_depth = self.max_depth if (!max_depth.is_a?(Numeric) || max_depth < 0) && !max_depth.nil?

      found = nil
      found_depth = -1

      container.pages.recursive_each do |page, depth|
        if depth < min_depth || !accept(page)
          continue
        end

        if page.active?(false) && depth > found_depth
          found = page
          found_depth = depth
        end
      end

      if max_depth.is_a?(Numeric) && found_depth > max_depth
        while found_depth > max_depth
          found_depth -= 1
          if found_depth < min_depth
            found = nil
            break
          end

          found = found.parent
          if !found.is_a?(Cinnamon::Navigation::Page)
            found = nil
            break
          end
        end
      end

      if found
        return {:page => found, :depth => found_depth}
      else
        return {}
      end
    end

    def htmlify(page)
      label = page.label
      title = page.title

      if label.is_a?(String) && !label.blank?
        label = I18n.t(label, :prefix => [:navigation])
      end
      if title.is_a?(String) && !title.blank?
        title = I18n.t(title, :prefix => [:navigation])
      end

      attrs = {
        :id => page.id,
        :title => title,
        :class => page.klass,
        :target => page.target
      }

      return link_to(label, page.href, attrs)
    end

    def accept(page, recursive = true)
      result = true

      if !page.visible?(false) && !@render_invisible
        result = false
      # TODO: Add ACL
      # elsif use_acl? && !accept_acl?(page)
      #   accept = false
      end

      if result && recursive
        parent = page.parent
        if parent.is_a?(Cinnamon::Navigation::Page)
          result = accept(parent, true)
        end
      end

      result
    end

    def render
      raise Exception, 'You should not use Renderer, use it’s children'
    end

    def to_s
      render
    end
  protected
    def whitespace(indent)
      if indent.is_a?(Numeric)
        indent = ' ' * indent
      end

      return indent.to_s
    end
  end

  class NavigationRenderer < Renderer
    @@default_options = {
      :ul_class => 'b_navigation',
      :only_active_branch => false,
      :render_parents => true,
      :partial = nil
    }
    attr_accessor :ul_class,
      :only_active_branch,
      :render_parents,
      :partial

    def menu(container = nil)
      if container
        self.container = container
      end
    end

    def ul_class=(klass)
      @ul_class = klass if klass.is_a?(String)
    end

    def only_active_branch=(enabled)
      @only_active_branch = !!enabled
    end

    def render_parents=(enabled)
      @render_parents = !!enabled
    end

    def partial=(partial)
      if partial.nil? || partial.is_a?(String) || partial.is_a?(Array)
        @partial = partial
      end
    end

  end

  class LinksRenderer < Renderer
    # TODO: LinksRenderer class
  end

  class BreadCrumbsRenderer < Renderer
    # TODO: BreadCrumbsRenderer class
  end

  class SitemapRenderer < Renderer
    # TODO: SitemapRenderer class
  end
end
