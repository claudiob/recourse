# Base class for recoursive controllers.
class RecoursesController < ApplicationController
  helper NavigableHelper, RecoursiveHelper, SearchableHelper
  include Pagy::Method

  def index
    model = controller_name.classify.constantize
    @where = request.path_parameters.except(:controller, :action)
    @order = model.recourse_order
    @includes = model.recourse_includes

    @pagy, @resources = paginate model, where: @where, order: model.recourse_order, includes: model.recourse_includes
  end

private

  def paginate(model, where: nil, includes: [], order: nil)
    if model.recourse_searchable? || model.recourse_sortable?
      @q = model.where(where).ransack params[:q]
      @q.sorts = (order || 'created_at desc') if @q.sorts.empty?
      pagy includes.present? ? @q.result.includes(includes) : @q.result.distinct(true)
    else
      pagy model.where(where).includes(includes).order(order)
    end
  end
end
