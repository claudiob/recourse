require_relative 'routes/nested'

module Recourse
  # Extends the config/routes.rb DSL, so `recourses` works anywhere `resources` does.
  module Routes
    include Nested

    # Draws what `resources` draws, after supplying any controller the host lacks. A
    # block nests what it declares under each resource — ZIPs at
    # `/counties/:county_id/zips` — with the nested controller namespaced after the
    # parent, so it and the top-level `ZIPsController` stay two controllers. Only a
    # `recourses` block adds that namespace, which every nested page relies on, so
    # nesting inside a plain `resources` block raises here rather than serving a
    # broken page. A `namespace` may sit in between — what is refused is a nesting
    # that adds no namespace at all. A nested resource defaults to
    # `only: %i[index new create]`, and an explicit `only:` or `except:` is the
    # host's word, which wins.
    def recourses(*names, **options, &block)
      refuse_unscoped_nesting names
      through = options.delete :through
      # Asked before the block, where every resource is its own parent. Top level
      # only: a resource nested under another is reached through its parent, and its
      # rows are kept at the resource's own route rather than at a second one drawn
      # under every parent that happens to list them.
      keepable = Recourse.bookmarks? && parent_resource.nil?

      names.each { |name| declare_resource name, through }
      options = default_nested_actions options
      # Only where there is a table to arrange: the place a row holds is written from
      # an index and from nowhere else.
      arrangeable = indexed? options

      return resources(*names, **options) unless block || through || keepable || arrangeable

      resources(*names, **options) { draw_within keepable, arrangeable, through, block }
    end

    # What `resource` draws, recorded the same way: one record reached without an id,
    # at `/providers/5/authentication`. Rails routes a singular resource to a plural
    # controller, so that is the path declared here — and recording it is the whole
    # point, since an action drawn with no index of its own earns its button on the
    # parent, and only a recorded nesting is ever looked for there.
    def recourse(*names, **)
      refuse_unscoped_nesting names

      names.each do |name|
        path = [current_module, name.to_s.pluralize].compact.join '/'
        record_declaration path
        Controllers.define_missing path
      end

      resource(*names, **)
    end

  private

    # The module is the namespace being drawn in, so a resource is declared and its
    # controller defined under the path Rails will route to.
    def declare_resource(name, through)
      path = [current_module, name].compact.join '/'
      record_declaration path
      Recourse.join path, through if through
      Controllers.define_missing path
    end

    # Whether `index` survived the `only:` or `except:` the host wrote. Neither of
    # them is the common case, and both name the action plainly.
    def indexed?(options)
      return Array(options[:except]).map(&:to_sym).exclude?(:index) if options.key? :except
      return Array(options[:only]).map(&:to_sym).include?(:index) if options.key? :only

      true
    end

    def default_nested_actions(options)
      return options if !parent_resource || options.key?(:only) || options.key?(:except)

      options.merge only: %i[index new create]
    end

    def refuse_unscoped_nesting(names)
      parent = parent_resource
      return if parent.nil? || current_module.to_s.split('/').include?(parent.name)

      raise Error, I18n.t('recourse.nested', names: names.map(&:inspect).join(', '),
                                             parent: parent.name)
    end
  end
end
