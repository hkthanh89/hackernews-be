class SingleNewsScraperService
  include ScraperHelpers

  def self.execute(url: )
    Rails.cache.fetch(url, expires_in: 2.days) do
      source = URI.open(URI.encode(url), ::USER_AGENT).read

      document = Nokogiri::HTML(source)

      image_url = ''
      og_image = document.at('meta[property="og:image"]')

      if og_image.present?
        image_url = element_content(og_image)
      else
        # get 1st img content (special for Hacker News page)
        link = document.at('a')
        image_url = "#{link.attributes['href'].value}/#{link.at('img').attributes['src'].value}"
      end

      title = ''
      og_title = document.at('meta[property="og:title"]')
      if og_title.present?
        title = element_content(og_title)
      else
        title = document.at('title').text
      end

      description = ''
      og_description = document.at('meta[property="og:description"]')
      if og_description.present?
        description = element_content(og_description)
      else
        description = document.at('p').text
      end

      News.new({
        url: url,
        cover_image_url: image_url,
        title: title,
        description: description,
        content: Readability::Document.new(source).content.gsub(/\t/, "")
      })
    end
  end
end