# A collection of helper methods used for navigation link in the admin-only section
module RecoursiveHelper
  # Adds a link next to the title to add a new resource.
  def button_link_to_add(name, path)
    content_for(:edit) { button_link_to "Add #{name}", path, class: 'btn-sm btn-outline ms-3' }
  end

private

  def button_link_to(name, path, options = {})
    link_to name, path, with_class('btn theme-primary', options)
  end

  def with_class(classes, options = {})
    options.merge class: [options[:class], classes].compact.join(' ')
  end
end
