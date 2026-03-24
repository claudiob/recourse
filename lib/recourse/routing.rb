# A module to manage administered resources.
module Recourse
  # Makes Recourse methods like `recourses` available in config/routes.rb
  module Routing
    # This method is equivalent to Rails `resources` with the added bonus that we store
    # the name of these administered resources so we can display them to admins in the navbar.
    def recourses(*administered_resources, concerns: nil, **options, &block)
      administered_resources.each { |resource| Recourse.resources[resource] = options }

      if block_given?
        error = 'recourses accepts only one resource if a block is given'
        raise ArgumentError, error unless administered_resources.one?
        administered_resource = administered_resources.sole
        resources administered_resource, concerns: concerns, **options do
          scope module: administered_resource, &block
        end
      else
        resources *administered_resources, concerns: concerns, **options, &block
      end
    end
  end
end

ActionDispatch::Routing::Mapper.include Recourse::Routing
