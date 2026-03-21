# Base class for controllers that require admin access
class RecourseController < ApplicationController
  helper RecoursiveHelper, SearchableHelper
  include Pagy::Method

  def index
    @model = controller_name.classify.constantize
    @pagy, @resources = paginate @model, order: @model.recourse_order, includes: @model.recourse_includes
    render 'recourse/index'
  end

private

  def paginate(model, includes: [], order: nil)
    if model.recourse_searchable? || model.recourse_sortable?
      @q = model.ransack params[:q]
      @q.sorts = (order || 'created_at desc') if @q.sorts.empty?
      pagy includes.present? ? @q.result.includes(includes) : @q.result.distinct(true)
    else
      pagy @model.includes(includes).order(order)
    end
  end
end
