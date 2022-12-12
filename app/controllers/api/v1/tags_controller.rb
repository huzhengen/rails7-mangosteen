class Api::V1::TagsController < ApplicationController
  def index
    current_user_id = request.env["current_user_id"]
    return head 401 if current_user_id.nil? # :unauthorized
    tags = Tag.where({ user_id: current_user_id }).page(params[:page] || 1)
    render json: { resources: tags, pager: {
      page: params[:page] || 1,
      per_page: Tag.default_per_page,
      count: Tag.count,
    } }
  end

  def create
    current_user_id = request.env["current_user_id"]
    return head 401 if current_user_id.nil? # :unauthorized
    tag = Tag.new name: params[:name], sign: params[:sign], user_id: current_user_id
    if tag.save
      render json: { resource: tag }
    else
      render json: { errors: tag.errors }, status: :unprocessable_entity # 422
    end
  end

  def update
    tag = Tag.find params[:id]
    tag.update params.permit(:name, :sign)
    if tag.errors.empty?
      render json: { resource: tag }
    else
      render json: { errors: tag.errors }, status: 422
    end
  end

  def destroy
    tag = Tag.find params[:id]
    return head :forbidden if tag.user_id != request.env["current_user_id"] # 403
    tag.deleted_at = Time.now
    if tag.save
      head 200
    else
      render json: { errors: tag.errors }, status: :unprocessable_entity # 422
    end
  end

  def show
    tag = Tag.find params[:id]
    return head :forbidden if tag.user_id != request.env["current_user_id"] # 403
    if tag.errors.empty?
      render json: { resource: tag }
    else
      render json: { errors: tag.errors }, status: 422
    end
  end
end
