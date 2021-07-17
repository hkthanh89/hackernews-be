require 'open-uri'
require 'resolv-replace'

module ScraperHelpers
  extend ActiveSupport::Concern

  class_methods do
    def parsed_document(url)
      html = URI.open(URI.encode(url), 'User-Agent' => 'Hackernews')
      Nokogiri::HTML(html)
    end

    def element_content(element)
      element.attributes['content'].value
    end
  end
end