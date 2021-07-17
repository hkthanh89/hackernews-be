require 'rails_helper'

RSpec.describe SingleNewsScraperService, type: :service do
  describe '.execute' do
    let(:url) { 'https://zwischenzugs.com/2021/07/12/if-you-want-to-transform-it-start-with-finance/' }

    let(:subject) do
      VCR.use_cassette('single_news') do
        described_class.execute(url: url)
      end
   end

    it 'should read url correctly' do
      expect(URI).to receive(:open).with(URI.encode(url)).and_call_original

      subject
    end

    it 'should return data correctly' do
      news = subject

      expect(news).to be_an_instance_of(News)
      expect(news.as_json).to eq(JSON.parse(File.new(Rails.root.join('spec', 'fixtures', 'news', 'single_news.json')).read))
    end
  end
end