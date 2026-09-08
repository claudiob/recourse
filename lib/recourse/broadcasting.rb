require 'active_support'

module Recourse
  # Extends every Active Record model with the refreshes its index listens for, so
  # a table redraws itself wherever it is open when a row of it changes.
  module Broadcasting
    # Whether saving a record refreshes every open index listing it. On for every
    # recoursed model; a host quiets one with `def recourse_broadcasts? = false`.
    def recourse_broadcasts? = true

    # True once the refresh broadcasts are attached, which is also what the index
    # checks before subscribing: a stream nobody broadcasts on is not worth a socket.
    def recourse_broadcasting? = @recourse_broadcasting || false

    # Attaches the broadcasts, once per class: every committed change goes to the
    # model's plural stream, the one its index subscribes to — plain
    # `broadcasts_refreshes` would send updates and destroys to per-record streams
    # the index never hears. The ivar dies with the class on a dev reload, so the
    # next request attaches to the fresh class again. Quiet without turbo-rails and
    # Active Job, which is when the model has no `broadcasts_refreshes_to`.
    def recourse_broadcast
      return if recourse_broadcasting? || !recourse_broadcasts?
      return unless respond_to? :broadcasts_refreshes_to

      @recourse_broadcasting = true
      broadcasts_refreshes_to ->(record) { record.model_name.plural }
    end
  end
end

ActiveSupport.on_load :active_record do
  extend Recourse::Broadcasting
end
