# A collection of helper methods used for navigation link in the admin-only section
module RecoursiveHelper
  def column(header:, **options, &block)
    if @recourse_headers
      tag.th header, **options.merge(scope: :col)
    else
      tag.td **options, &block
    end
  end
end
