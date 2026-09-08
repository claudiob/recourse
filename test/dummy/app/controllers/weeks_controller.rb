# A page of something this app works out rather than keeps. The rows are the whole of
# the override: the chrome, the crumbs and the paging still come from the gem.
class WeeksController < RecoursesController
private

  def recourse_relation = Week.all
end
