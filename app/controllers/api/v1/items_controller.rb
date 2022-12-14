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
    item = Item.new params.permit(:amount, :happen_at, tags_id: [])
    item.user_id = current_user_id
    if item.save
      render json: { resource: item }
    else
      render json: { errors: item.errors }, status: :unprocessable_entity # 422
    end
  end

  def summary
    current_user_id = request.env["current_user_id"]
    return head 401 if current_user_id.nil?
    hash = Hash.new
    items = Item.where(user_id: current_user_id).where(kind: params[:kind])
      .where({ happen_at: params[:happened_after]..params[:happened_before] })
    items.each do |item|
      if params[:group_by] == "happen_at"
        key = item.happen_at.in_time_zone("Beijing").strftime("%F")
        hash[key] ||= 0
        hash[key] += item.amount
      else
        item.tags_id.each do |tag_id|
          key = tag_id
          hash[key] ||= 0
          hash[key] += item.amount
        end
      end
    end
    groups = hash
      .map { |key, value| { "#{params[:group_by]}": key, amount: value } }
    if params[:group_by] == "happen_at"
      groups.sort! { |a, b| a[:happen_at] <=> b[:happen_at] }
    elsif params[:group_by] == "tag_id"
      groups.sort! { |a, b| b[:amount] <=> a[:amount] }
    end
    render json: {
             groups: groups,
             total: items.sum(:amount),
           }
  end
end
