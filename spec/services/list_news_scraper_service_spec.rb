require 'rails_helper'

RSpec.describe ListNewsScraperService, type: :service do
  describe '.execute' do
    let(:cassette) { 'list_news' }
    let(:subject) do
      VCR.use_cassette(cassette) do
        described_class.execute(page: nil)
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
        description: '2460 points by homarp 1 day ago  | 1546 comments',
        content: nil
      }.as_json)
    end

    context 'caching' do
      context 'when cache does not exist' do
        it 'should send request to get data' do
          expect(URI).to receive(:open).with("#{::SOURCE_URL}?p=1", 'User-Agent' => 'Hackernews').once

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