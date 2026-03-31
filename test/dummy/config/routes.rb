Rails.application.routes.draw do
  recourses :users, except: :show
  recourses :babies, only: :index do
    recourses :posts, :words, only: :index
  end
  recourses :fans, :posts, :tasks, only: :index
end
