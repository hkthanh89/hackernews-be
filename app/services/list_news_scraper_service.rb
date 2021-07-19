class ListNewsScraperService
  include ScraperHelpers

  def self.execute(page: )
    page = page.to_i > 0 ? page.to_i : 1
    url = "#{::SOURCE_URL}?p=#{page}"

    Rails.cache.fetch(url, expires_in: 100.minutes) do
      data = []

      document = parsed_document(url)

      item_list = document.css('.itemlist')

      title_elements = item_list.css('tr.athing td.title+td+td')
      title_elements.each_with_index do |title_elm, index|
        title = title_elm.css('.storylink')

        news = News.new({
          url: title.attribute('href').value,
          title: title.text,
          sub_title: title_elm.css('.sitestr').text,
        })

        data << news
      end

      news_details = {}
      threads = []
      data.each do |news|
        threads << Thread.new do
          begin
            news_url = news.url

            news_details[news_url] = {}

            document = parsed_document(news_url)

            description = ''
            og_description = document.at('meta[property="og:description"]') || document.at('meta[property="description"]')
            description = if og_description.present?
              element_content(og_description)
            else
              document.at('p').text
            end
            news_details[news_url][:description] = description.gsub(/\n/, '').strip.truncate(160)

            og_image = document.at('meta[property="og:image"]')
            image_url = og_image.attributes['content'].value
            news_details[news_url][:cover_image_url] = image_url
          rescue StandardError
            news_details[news_url][:cover_image_url] = ''
          end
        end
      end
      threads.map(&:join)

      data.each do |news|
        news.description = news_details[news.url][:description]
        news.cover_image_url = news_details[news.url][:cover_image_url]
      end

      data
    end
  end
end