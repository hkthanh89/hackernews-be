class SingleNewsScraperService
  include ScraperHelpers

  def self.execute(url: )
    Rails.cache.fetch(url, expires_in: 2.days) do
      source = URI.open(URI.encode(url), ::USER_AGENT).read

      document = Nokogiri::HTML(source)

      og_title = document.at('meta[property="og:title"]')
      title = if og_title.present?
        element_content(og_title)
      else
        document.at('title').text
      end

      og_description = document.at('meta[property="og:description"]')
      description = if og_description.present?
        element_content(og_description)
      else
        document.at('p').text
      end

      og_image = document.at('meta[property="og:image"]')
      image_url = if og_image.present?
        element_content(og_image)
      else
        # get 1st img content (special for Hacker News page)
        link = document.at('a')

        if link.attributes['href'] && link.at('img')
          "#{link.attributes['href'].value}/#{link.at('img').attributes['src'].value}"
        else
          ""
        end
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