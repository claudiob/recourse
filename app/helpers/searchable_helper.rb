# A collection of helper methods used to search resources with Ransack.
module SearchableHelper
  # Renders a form with a field to search within +model+ that uses +placeholder+.
  # @param [String] q the search query.
  # @param [ApplicationRecord] model the model of each object returned by the search
  def search_form(q:, model:, url: url_for(model))
    search_form_for(q, search_form_params(url: url)) do |form|
      safe_join [*filter_fields_for(form, model:), search_field_for(form, model:)].compact
    end
  end

  # Highlights the search query within the text of the matched content.
  def search_highlight(content, model:)
    highlight content.to_s, params.dig(:q, model.search_field)
  end

private

  def filter_fields_for(form, model:)
    selects = model.filter_fields.map do |method, options = {}|
      choices = options.delete :choices
      form.select method, choices, options, filter_field_params if choices
    end
    safe_join selects.compact
  end

  def search_field_for(form, model:)
    return unless model.search_field
    adorn = tag.svg width: 16, height: 16, viewBox: '0 0 16 16', xmlns: 'http://www.w3.org/2000/svg' do
      tag.path d: 'M11.742 10.344a6.5 6.5 0 1 0-1.397 1.398h-.001q.044.06.098.115l3.85 3.85a1 1 0 0 0 1.415-1.414l-3.85-3.85a1 1 0 0 0-.115-.1zM12 6.5a5.5 5.5 0 1 1-11 0 5.5 5.5 0 0 1 11 0'
    end
    field = form.search_field model.search_field, search_field_params(placeholder: model.search_prompt)
    tag.div safe_join([adorn, field]), class: 'form-control form-control-sm form-adorn'
  end

  def search_form_params(url:)
    {
      url: url, class: 'col-6 d-flex pe-4', role: 'search',
      data: { turbo_frame: :results, turbo_action: :advance },
    }
  end

  def search_field_params(placeholder:)
    {
      class: 'form-ghost', placeholder: placeholder,
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
