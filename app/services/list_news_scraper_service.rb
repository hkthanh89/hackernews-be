class ListNewsScraperService
  include ScraperHelpers

  def self.execute(page: )
    page = page.to_i > 0 ? page.to_i : 1
    url = "https://news.ycombinator.com/best?p=#{page}"

    Rails.cache.fetch(url, expires_in: 5.days) do
      data = []

      document = parsed_document(url)

      item_list = document.css('.itemlist')

      titles = item_list.css('.storylink')
      titles.each do |title|
        news = News.new({ title: title.text, url: title.attributes['href'].value })
        data << news
      end

      sub_titles = item_list.css('.sitestr')
      sub_titles.each_with_index do |sub_title, index|
        data[index].sub_title = sub_title.text
      end

      descriptions = item_list.css('.subtext')
      descriptions.each_with_index do |desc, index|
        data[index].description = desc.text.gsub(/\n/, "").strip
      end

      cover_image_urls = {}
      threads = []
      data.each do |news|
        threads << Thread.new do
          document = parsed_document(news.url)
          og_image = document.at('meta[property="og:image"]')

          image_url = og_image.present? ? og_image.attributes['content'].value : ''
          cover_image_urls[news.url] = image_url
        end
      end
      threads.map(&:join)

      data.each do |news|
        news.cover_image_url = cover_image_urls[news.url]
      end

      data
    end
  end
end