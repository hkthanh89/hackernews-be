require 'open-uri'
require 'resolv-replace'

module ScraperHelpers
  extend ActiveSupport::Concern

  class_methods do
    def parsed_document(url)
      html = URI.open(url, 'User-Agent' => 'Hackernews')
      Nokogiri::HTML(html)
    end
  end
end