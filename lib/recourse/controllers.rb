module Recourse
  # Defines the controller classes a host app has not written for itself.
  module Controllers
    @held = []
    @lock = Mutex.new

    # Creates a controller for the named resource unless the host app has one. The
    # name arrives with whatever namespace it was drawn in — `admin/contacts` — so
    # the constant lands where Rails will look for it. A block names the superclass,
    # `RecoursesController` by default, and is called only once the class is made.
    def self.define_missing(path, &base)
      class_name = "#{path.camelize}Controller"
      # const_defined? is true for a Zeitwerk autoload, so files on disk count too.
      return if Object.const_defined? class_name

      booting? ? hold(class_name, base) : define(class_name, base)
    end

    # Makes the controllers held back while the app booted. The executor runs this
    # ahead of the app's first request or job, once every class may be loaded.
    def self.define_held
      @lock.synchronize { define(*@held.shift) until @held.empty? }
    end

    private_class_method def self.define(class_name, base)
      superclass = base ? base.call : RecoursesController
      namespace(class_name.deconstantize).const_set class_name.demodulize, Class.new(superclass)
    end

    # Rails 8.2 warns when Action Controller is loaded during the boot of an app that
    # will not eager load — a rake task's, which draws its routes before it is done
    # and never dispatches to a controller — so the class waits for the first run.
    private_class_method def self.booting?
      app = Rails.application
      app.present? && !app.config.eager_load && !app.initialized?
    end

    private_class_method def self.hold(class_name, base)
      Rails.application.executor.to_run { Controllers.define_held } if @held.empty?
      @held << [class_name, base]
    end

    # The module a namespaced controller belongs in, made where the host has none of
    # its own: `namespace :admin` draws routes whether or not an `Admin` exists.
    private_class_method def self.namespace(name)
      name.split('::').reduce Object do |scope, part|
        next scope.const_get part, false if scope.const_defined? part, false

        scope.const_set part, Module.new
      end
    end
  end
end
