class SingleNewsScraperService
  include ScraperHelpers

  def self.execute(url: )
    Rails.cache.fetch(url, expires_in: 5.days) do
      source = URI.open(URI.encode(url)).read

      document = parsed_document(url)

      image = document.at('meta[property="og:image"]')
      title = document.at('meta[property="og:title"]').attributes['content'].value
      description = document.at('meta[property="og:description"]').attributes['content'].value

      News.new({
        url: url,
        cover_image_url: image.present? ? image.attributes['content'].value : '',
        title: title,
        description: description,
        content: Readability::Document.new(source).content
      })
    end
  end
end