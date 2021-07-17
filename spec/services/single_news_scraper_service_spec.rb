require 'rails_helper'

RSpec.describe SingleNewsScraperService, type: :service do
  describe '.execute' do
    let(:url) { 'https://zwischenzugs.com/2021/07/12/if-you-want-to-transform-it-start-with-finance/' }
    let(:cassette) { 'single_news' }

    let(:subject) do
      VCR.use_cassette(cassette) do
        described_class.execute(url: url)
      end
    end

    before(:each) { Rails.cache.clear }

    it 'should read url correctly' do
      expect(URI).to receive(:open).with(URI.encode(url), ::USER_AGENT).and_call_original

      subject
    end

    it 'should return data correctly' do
      news = subject

      expect(news).to be_an_instance_of(News)
      expect(news.as_json).to eq(JSON.parse(File.new(Rails.root.join('spec', 'fixtures', 'news', 'single_news.json')).read))
    end

    context 'caching' do
      context 'when cache does not exist' do
        it 'should send request to get data' do
          expect(URI).to receive(:open).once.and_call_original

          subject
        end
      end

      context 'when cache exists' do
        it 'should get data from cache' do
          subject

          expect(URI).not_to receive(:open)

          described_class.execute(url: url)
        end
      end
    end

    context 'when og metadata is missing' do
      let(:url) { 'https://news.ycombinator.com/item?id=27830978' }
      let(:cassette) { 'single_hacker_news' }

      context 'when og:image is missing' do
        it 'should get first image' do
          news = subject

          expect(news.as_json['cover_image_url']).to eq('https://news.ycombinator.com/y18.gif')
        end
      end

      context 'when og:title is missing' do
        it 'should get title tag' do
          news = subject

          expect(news.as_json['title']).to eq('Launch HN: Onfolk (YC S21) – Modern HR and Payroll in One Place (For the UK) | Hacker News')
        end
      end

      context 'when og:description is missing' do
        it 'should get first paragraph' do
          news = subject

          expect(news.as_json['description']).to eq("To set the scene: we were software engineers at Monzo for 4 years. Joined at 400k customers, left at 5.5M. We took voluntary furlough in April 2020 (\"furlough\" is the UK government’s scheme for keeping workers paid for a bit so that companies don't have to lay them off). During that time, Monzo changed payroll provider. The old one sucked and had errors. The new one sucked and had errors. It took a consultant a year to implement the new one.")
        end
      end
    end
  end
end