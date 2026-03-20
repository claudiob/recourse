# A collection of helper methods used for navigation link in the admin-only section
module SearchableHelper
  # Renders a form with a field to search within +model+ that uses +placeholder+.
  # @param [String] q the search query.
  # @param [ApplicationRecord] model the model of each object returned by the search
  def search_form(q:, model:, url: url_for(model))
    search_form_for(q, search_form_params(url: url)) do |form|
      safe_join [filter_field_for(form, model:), search_field_for(form, model:)].compact
    end
  end

  # Highlights the search query within the text of the matched content.
  def search_highlight(content, model:)
    highlight content.to_s, params.dig(:q, model.search_field)
  end

private

  def filter_field_for(form, model:)
    method = model.filter_field
    choices = model.filter_choices
    options = { prompt: model.filter_prompt }
    form.select method, choices, options, filter_field_params if method && choices
  end

  def search_field_for(form, model:)
    form.search_field model.search_field, search_field_params(placeholder: model.search_placeholder)
  end

  def search_form_params(url:)
    {
      url: url, class: 'col-8 col-sm-6 col-md-4 d-flex', role: 'search',
      data: { turbo_frame: :results, turbo_action: :advance },
    }
  end

  def search_field_params(placeholder:)
    {
      class: 'form-control form-control-sm flex-grow-1', placeholder: placeholder,
      oninput: 'debouncedSubmit(this.form)', aria: { label: 'Search' }
    }
  end

  def filter_field_params
    {
      aria: { label: 'Filter' }, class: 'form-control form-control-sm me-3',
      onchange: 'debouncedSubmit(this.form)',
    }
  end
end
