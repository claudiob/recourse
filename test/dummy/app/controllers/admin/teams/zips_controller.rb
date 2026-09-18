# The ZIPs a team's places stand in, which no column on a ZIP says -- so the relation is
# the team's own, and it carries the answer as a value of its own beside the ZIP's columns.
class Admin::Teams::ZipsController < RecoursesController
private

  def recourse_relation
    ZIP.left_joins(:places).group('zips.id')
       .select ZIP.sanitize_sql_array ['zips.*, MAX(places.team_id = ?) AS kept', @team.id]
  end
end
