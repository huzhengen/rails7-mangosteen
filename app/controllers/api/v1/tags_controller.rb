class Api::V1::TagsController < ApplicationController
  def index
    current_user_id = request.env["current_user_id"]
    return head 401 if current_user_id.nil? # :unauthorized
    tags = Tag.where({ user_id: current_user_id }).page(params[:page] || 1)
    tags = tags.where({ kind: params[:kind] }) unless params[:kind].nil?
    render json: { resources: tags, pager: {
      page: params[:page] || 1,
      per_page: Tag.default_per_page,
      count: tags.count,
    } }
  end

  def create
    current_user = User.find request.env["current_user_id"]
    return head 401 if current_user.nil?
    tag = Tag.new params.permit(:name, :sign, :kind)
    tag.user = current_user
    if tag.save
      render json: { resource: tag }, status: :ok
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
    return head :forbidden unless tag.user_id == request.env["current_user_id"]
    tag.deleted_at = Time.now
    ActiveRecord::Base.transaction do
      begin
        Item.where("tag_ids && ARRAY[?]::bigint[]", [tag.id])
            .update!(deleted_at: Time.now)
        tag.save!
      rescue
        return head 422
      end
      head 200
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
