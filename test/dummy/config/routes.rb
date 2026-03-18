Rails.application.routes.draw do
  recourses :users, except: :show
  recourses :babies, :fans, :posts, :tasks, only: :index
end
