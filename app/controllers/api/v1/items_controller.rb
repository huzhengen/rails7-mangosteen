class Api::V1::ItemsController < ApplicationController
  def index
    current_user_id = request.env["current_user_id"]
    return head 401 if current_user_id.nil? # :unauthorized
    # items = Item.where("id > ?", params[:start_id]).limit(100)
    items = Item.where({ user_id: current_user_id }).where({ created_at: params[:created_after]..params[:created_before] })
      .page(params[:page] || 1)
    render json: { resources: items, pager: {
      page: params[:page] || 1,
      per_page: Item.default_per_page,
      count: Item.count,
    } }
  end

  def create
    current_user_id = request.env["current_user_id"]
    return head 401 if current_user_id.nil? # :unauthorized
    # item = Item.new amount: params[:amount], tags_id: params[:tags_id], happen_at: params[:happen_at], user_id: current_user_id
    item = Item.new params.permit(:amount, :tags_id, :happen_at)
    item.user_id = current_user_id
    if item.save
      render json: { resource: item }
    else
      render json: { errors: item.errors }, status: :unprocessable_entity # 422
    end
  end
end
