require 'rails_helper'

RSpec.describe News, type: :model do
  describe '.initialize' do
    it 'should set data correctly' do
      attributes = {
        url: 'http://sample.com',
        title: 'Sample',
        sub_title: 'samplesite',
        content: 'content',
        description: 'description',
        cover_image_url: 'http://sample.com/sample.jpg'
      }
      news = News.new(attributes)
      json = news.as_json

      expect(json['url']).to eq(attributes[:url])
      expect(json['title']).to eq(attributes[:title])
      expect(json['sub_title']).to eq(attributes[:sub_title])
      expect(json['content']).to eq(attributes[:content])
      expect(json['description']).to eq(attributes[:description])
      expect(json['cover_image_url']).to eq(attributes[:cover_image_url])

    end
  end
end