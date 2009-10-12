module Cinnamon
  module Helpers
    def cinnamon
      @cinnamon ||= Cinnamon::Application.new
    end

    def application_meta
      returning('') do |result|
        result << tag(:meta, :'http-equiv' => 'Content-type', :content => 'text/html; charset=UTF-8')
        result << tag(:meta, :name => 'Description', :content => cinnamon.description) +
          tag(:meta, :name => 'Keywords', :content => cinnamon.keywords) +
          tag(:meta, :name => 'application-name', :content => cinnamon.name) +
          tag(:meta, :name => 'application-url', :content => cinnamon.url)
        if cinnamon.icons?
          result << tag(:link, :rel => 'icon', :type => 'image/x-icon', :href => cinnamon.favicon) +
            tag(:link, :rel => 'shortcut icon', :type => 'image/x-icon', :href => cinnamon.favicon)
          # TODO: add icons for Google Chrome Ap
          # cinnamon.icons.each do |icon|
          #
          # end
        end
        result << content_tag(:title, cinnamon.title)
      end
    end
  end
end
