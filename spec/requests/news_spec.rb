require 'rails_helper'

RSpec.describe 'News', type: :request do
  let(:news_schema) { 'spec/schemas/news.json' }
  let(:params) { {} }

  let(:subject) do
    VCR.use_cassette(cassette) do
      get '/news', params: params
    end
  end

  describe 'GET List News' do
    let(:cassette) { 'list_news' }

    before(:each) { Rails.cache.clear }

    shared_examples 'fetch_list_news' do
      it 'returns http success' do
        subject

        expect(response).to have_http_status(:success)
      end

      it 'fetchs enough data' do
        subject

        expect(JSON.parse(response.body)['data'].length).to eq(30)
      end

      it 'returns data correctly' do
        subject

        expect(JSON::Validator.validate(news_schema, JSON.parse(response.body)['data'], list: true, clear_cache: true)).to eq(true)
      end
    end

    context 'without pagination param' do
      include_examples 'fetch_list_news'

      it 'fetchs data correct page' do
        expect(URI).to receive(:open).with(URI.encode("#{::SOURCE_URL}?p=1"), ::USER_AGENT)

        subject
      end
    end

    context 'with pagination param' do
      let(:cassette) { 'list_news_page_2' }
      let(:params) { { page: 2 } }

      include_examples 'fetch_list_news'

      it 'fetchs data correct page' do
        expect(URI).to receive(:open).with(URI.encode("#{::SOURCE_URL}?p=2"), ::USER_AGENT)

        subject
      end
    end
  end

  describe 'GET Single News' do
    let(:cassette) { 'single_news' }
    let(:params) { { url: 'https://zwischenzugs.com/2021/07/12/if-you-want-to-transform-it-start-with-finance/' } }

    it 'returns http success' do
      subject

      expect(response).to have_http_status(:success)
    end

    it 'fetchs data correctly' do
      subject

      expect(JSON::Validator.validate(news_schema, JSON.parse(response.body)['data'], clear_cache: true)).to eq(true)
    end
  end
end
