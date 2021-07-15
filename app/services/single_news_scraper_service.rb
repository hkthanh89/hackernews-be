class SingleNewsScraperService
  include ScraperHelpers

  def self.execute(url: )
    source = URI.open(url).read

    document = parsed_document(url)

    image = document.at('meta[property="og:image"]')
    title = document.at('meta[property="og:title"]')
    description = document.at('meta[property="og:description"]')

    News.new({
      url: url,
      cover_image_url: image.present? ? image.attributes['content'].value : '',
      title: title.attributes['content'].value,
      description: description.attributes['content'].value,
      content: Readability::Document.new(source).content
    })
  end
end