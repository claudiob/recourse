module Recourse
  module Helpers
    # The sidebar: one entry per resource the routes declared, in that order, and
    # whatever the host adds below them.
    module Sidebars
    private

      # What the sidebar carries below the resources: an app's own way out of it,
      # and whatever else the routes cannot name. A host answers `recourse_extra_links`
      # with `[label, path, method]` — the method only where the link is a button, as
      # a log out is — the way it answers `recourse_extra_tabs` for one record.
      def sidebar_extras
        return [] unless respond_to? :recourse_extra_links

        recourse_extra_links
      end

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
