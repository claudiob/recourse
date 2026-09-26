module Recourse
  module Helpers
    # The sidebar: one entry per resource the routes declared, in that order, and
    # the way out where the host drew one.
    module Sidebars
    private

      # Whether the host drew a way out. A route named `exit` — `resource :session,
      # only: :destroy, as: :exit` — is the whole declaration: the name is the
      # convention, and its helper existing is what the sidebar asks.
      def exit? = respond_to? :exit_path

      # And the way in, its mirror: a route named `enter` — `resource :session, only:
      # :new, as: :enter`, or a `get` of the host's own — earns a link beside the toggle
      # to wherever the host signs people in. A link rather than a button, since asking
      # for a form to sign in with changes nothing. Whether a viewer who already signed
      # in still sees it is the host's to say, by answering this for them.
      def enter? = respond_to? :enter_path

      # Sidebar entries as [name, title, path, key], in the order routes.rb declares
      # them, `key` being where in the title the letter that reaches it sits.
      def sidebar_resources
        taken = []

        Recourse.declared.filter_map do |path|
          next unless routed? path, 'index'

          title = Recourse.title path
          [
            path, title, url_for(controller: "/#{path}", action: :index),
            shortcut_index(title, taken),
          ]
        end
      end

      # True when a sidebar entry names the page being shown, or the parent a nested
      # page sits under. The whole path, so a namespaced resource and its top-level
      # twin are not each other.
      def current_resource?(path)
        here = controller.controller_path

        path == here || here.start_with?("#{path}/")
      end
    end
  end
end
