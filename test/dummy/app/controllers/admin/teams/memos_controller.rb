module Admin
  module Teams
    # The one host controller in this app: every other screen the gem serves whole. A
    # memo names no team, so a route under one has to say what it lists -- here, the
    # memos of the people whose places this team keeps. That is the whole of the
    # override: the search, the sort, the filters, the page and the cache still come
    # from the gem, and the scope is a line of this app's own.
    class MemosController < RecoursesController
    private

      def recourse_relation
        team = Team.find params.expect(:team_id)

        Memo.where person: Person.where(id: team.places.select(:person_id))
      end
    end
  end
end
