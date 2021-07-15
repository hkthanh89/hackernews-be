class News
  attr_accessor :url, :cover_image_url, :title, :sub_title, :description, :content

  def initialize(attributes = {})
    @url = attributes[:url]
    @cover_image_url = attributes[:cover_image_url]
    @title = attributes[:title]
    @sub_title = attributes[:sub_title]
    @description = attributes[:description]
    @content = attributes[:content]
  end
end