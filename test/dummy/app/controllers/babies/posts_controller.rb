class Babies::PostsController < RecoursesController
  before_action :set_baby

  def index
    @model = Post
    @pagy, @resources = paginate @baby.posts
  end

private

  def set_baby
    @baby = Baby.find params.expect(:baby_id)
  end
end
