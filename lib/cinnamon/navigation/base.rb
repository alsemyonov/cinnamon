module Cinnamon
  module Navigation
    class Base < Container
      def initialize(pages)
        super
        if pages.is_a?(Hash)
          self.add_pages(pages)
        elsif !pages.nil?
          raise Exception, 'pages must be a hash or nil'
        end
      end
    end
  end
end
