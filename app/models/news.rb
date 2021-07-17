class News
  attr_reader :url
  attr_writer :cover_image_url

  def initialize(attributes = {})
    @url = attributes[:url]
    @cover_image_url = attributes[:cover_image_url]
    @title = attributes[:title]
    @sub_title = attributes[:sub_title]
    @description = attributes[:description]
    @content = attributes[:content]
  end
end