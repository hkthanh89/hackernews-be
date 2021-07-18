class ListNewsScraperService
  include ScraperHelpers

  def self.execute(page: )
    page = page.to_i > 0 ? page.to_i : 1
    url = "#{::SOURCE_URL}?p=#{page}"

    Rails.cache.fetch(url, expires_in: 15.minutes) do
      data = []

      document = parsed_document(url)

      item_list = document.css('.itemlist')

      title_elements = item_list.css('tr.athing td.title+td+td')
      description_elements = item_list.css('.subtext')

      title_elements.each_with_index do |title_elm, index|
        title = title_elm.css('.storylink')

        news = News.new({
          url: title.attribute('href').value,
          title: title.text,
          sub_title: title_elm.css('.sitestr').text,
          description: description_elements[index].text.gsub(/\n/, '').strip
        })

        data << news
      end

      cover_image_urls = {}
      threads = []
      data.each do |news|
        threads << Thread.new do
          begin
            news_url = news.url

            document = parsed_document(news_url)
            og_image = document.at('meta[property="og:image"]')

            image_url = og_image.attributes['content'].value
            cover_image_urls[news_url] = image_url
          rescue StandardError
            cover_image_urls[news_url] = ''
          end
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