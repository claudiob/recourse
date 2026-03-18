# Base class for controllers that require admin access
class RecourseController < ApplicationController
  include Pagy::Method

  def index
    @model = controller_name.classify.constantize
    @pagy, @resources = paginate @model, order: @model.recourse_order, includes: @model.recourse_includes
    render 'recourse/index'
  end

private

  def paginate(model, order:, includes:)
    if model.recourse_searchable?
      @q = model.ransack params[:q]
      @q.sorts = order if order && @q.sorts.empty?
      pagy includes.present? ? @q.result.includes(includes) : @q.result.distinct(true)
    else
      pagy @model.includes(includes).order(order)
    end
  end
end
