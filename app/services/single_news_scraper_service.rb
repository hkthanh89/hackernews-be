class SingleNewsScraperService
  include ScraperHelpers

  def self.execute(url: )
    Rails.cache.fetch(url, expires_in: 2.days) do
      source = URI.open(URI.encode(url)).read

      document = Nokogiri::HTML(source)

      image = document.at('meta[property="og:image"]')
      title = document.at('meta[property="og:title"]').attributes['content'].value
      description = document.at('meta[property="og:description"]').attributes['content'].value

      News.new({
        url: url,
        cover_image_url: image.present? ? image.attributes['content'].value : '',
        title: title,
        description: description,
        content: Readability::Document.new(source).content.gsub(/\t/, "")
      })
    end
  end
end