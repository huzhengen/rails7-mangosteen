class Api::V1::ItemsController < ApplicationController
  def index
    # items = Item.where("id > ?", params[:start_id]).limit(100)
    items = Item.page(params[:page]).per(params[:per_page])
    render json: { resources: items, pager: {
      page: params[:page]
      per_page: 100,
      count: Item.count,
    } }
  end

  def create
    item = Item.new amount: 1
    if item.save
      render json: { resources: item }
    else
      render json: { errors: item.errors }
    end
  end
end
