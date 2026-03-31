# A module to manage administered resources.
module Recourse
  # Makes Recourse methods like `recourses` available in config/routes.rb
  module Routing
    # This method is equivalent to Rails `resources` with the added bonus that we store
    # the name of these administered resources so we can display them to admins in the navbar.
    def recourses(*args, **kwargs, &block)
      store_recourses args, kwargs
      resources(*args, **kwargs, &scoped(args, &block))
    end

  private

    def store_recourses(args, kwargs)
      if @scope[:scope_level_resource]
        Recourse.resources[@scope[:scope_level_resource].name.to_sym][:nested] = args
      else
        routes = Array(kwargs.fetch :only, self.class::Resource.default_actions(false))
        routes-= Array(kwargs.fetch :except, [])

        Recourse.resources.merge! args.to_h { |arg| [arg, { module: @scope[:module], routes: routes }] }
      end
    end

    def scoped(args, &block)
      return unless block_given?

      parent_module = args.sole
      Proc.new { scope module: parent_module, &block }
      # :nocov:
    rescue Enumerable::SoleItemExpectedError
      raise ArgumentError, 'recourses accepts only one resource if a block is given'
      # :nocov:
    end
  end
end

ActionDispatch::Routing::Mapper.include Recourse::Routing
