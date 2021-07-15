class NewsController < ApplicationController
  def index
    if params[:url].present?
      data = SingleNewsScraperService.execute(url: params[:url])
    else
      data = ListNewsScraperService.execute
    end

    render json: { data: data }
  end
end
