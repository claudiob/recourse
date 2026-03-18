# A module to manage administered resources.
module Recourse
  # Makes Recourse methods like `recourses` available in config/routes.rb
  module Routing
    # This method is equivalent to Rails `resources` with the added bonus that we store
    # the name of these administered resources so we can display them to admins in the navbar.
    def recourses(*administered_resources, concerns: nil, **options, &block)
      # NOTE: only is not enough, I need the except as well
      administered_resources.each { |resource| Recourse.resources[resource] = options }
      resources *administered_resources, concerns: concerns, **options, &block
    end
  end
end

ActionDispatch::Routing::Mapper.include Recourse::Routing
