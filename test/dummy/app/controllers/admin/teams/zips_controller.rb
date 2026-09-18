# The ZIPs a team's places stand in, which no column on a ZIP says -- so the relation
# is the team's own rather than the one a foreign key would give.
class Admin::Teams::ZipsController < RecoursesController
private

  def recourse_relation = @team.zips.distinct
end
