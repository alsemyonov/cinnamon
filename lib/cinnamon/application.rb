module Cinnamon
  module Application
    attr_accessor :name, :description, :keywords, :icons,
      :breadcrumbs

    def initialize
      @breadcrumbs = []
      @keywords = []
      @menu_separator = ' | '

    end

    def add_title(title)
      @breadcrumbs << title
    end

    def keywords
      compact.uniq.join(', ')
    end

    def title
      (@breadcrumbs + [name]).join(@menu_separator)
    end
  end
end
