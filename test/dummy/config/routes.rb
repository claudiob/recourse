Rails.application.routes.draw do
  recourses :users, except: :show
  recourses :babies, only: :index do
    resources :posts, only: :index
  end
  recourses :fans, :posts, :tasks, only: :index
end
