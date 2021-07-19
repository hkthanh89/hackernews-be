require 'rails_helper'

RSpec.describe ListNewsScraperService, type: :service do
  describe '.execute' do
    let(:cassette) { 'list_news' }
    let(:page) { nil }
    let(:subject) do
      VCR.use_cassette(cassette) do
        described_class.execute(page: page)
      end
    end

    before(:each) { Rails.cache.clear }

    it 'should create correct data' do
      data = subject

      expect(data.length).to eq(30)
      expect(data).to all(be_a(News))
    end

    it 'should create correct Threads to fetch cover image' do
      expect(Thread).to receive(:new).exactly(30).time.and_call_original
      subject
    end

    it 'should create correct News information' do
      data = subject
      news = data[0]

      expect(news.as_json).to eq({
        url: 'https://www.steamdeck.com/en/',
        cover_image_url: 'https://cdn.cloudflare.steamstatic.com/steamdeck/images/steamdeck_social.jpg',
        title: 'Valve Steam Deck',
        sub_title: 'steamdeck.com',
        description: 'Steam Deck is a powerful handheld gaming PC that delivers the Steam games and features you love.',
        content: nil
      }.as_json)
    end

    context 'encoding format' do
      let(:cassette) { 'list_news_page_2' }
      let(:page) { 2 }

      it 'should parse document as UTF-8' do
        data = subject
        news = data[24]

        expect(news.as_json).to eq({
          url: 'https://www.ana.press/photo/548339/دنیای-مداد-رنگی',
          cover_image_url: 'https://media.ana.press/old/1399/09/24/637435500045793867_lg.JPG',
          title: 'Mr. Rafieh’s Tehran Pencil Shop',
          sub_title: 'ana.press',
          description: 'در راهرو های باریک بازار لوازم التحریر که گذر می کنیم یک نام برای همه بسیار آشناست و آدرس دکه اش برای در ذهن کسبه حک شده. اگر دنبال مداد رنگی باشی همه آقا رف...',
          content: nil
        }.as_json)
      end
    end

    context 'caching' do
      context 'when cache does not exist' do
        it 'should send request to get data' do
          expect(URI).to receive(:open).with("#{::SOURCE_URL}?p=1", ::USER_AGENT).once

          subject
        end
      end

      context 'when cache exists' do
        it 'should get data from cache' do
          subject

          expect(URI).not_to receive(:open)

          described_class.execute(page: nil)
        end
      end
    end
  end
end