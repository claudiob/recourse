module Recourse
  module Helpers
    # A value that is a web address rather than words: how one is recognised, and how
    # it reads once it is.
    module Links
      # One absolute web address and nothing else: a value to follow, not to read.
      # Anything around it — words, a second address — reads as text instead. What it
      # captures is what a link says: the host, less any `www.`, and whatever follows.
      WEB_URL = %r{\Ahttps?://(?:www\.)?([^/?#\s]+)(\S*)\z}

    private

      def web_url?(value) = value.is_a?(String) && value.match?(WEB_URL)

      # The words lead where the value points, in this tab, the way any link does; the
      # arrow after them — Bootstrap's icon link, stepping under the cursor — opens the
      # same address in a new tab. Either reads as the host, and an ellipsis where the
      # address goes further: a path is how a machine finds the page, and the href has it.
      def url_link(value)
        host, rest = value.match(WEB_URL).captures
        said = rest.delete_suffix('/').empty? ? host : "#{host}/…"

        safe_join [tag.a(said, href: value), new_tab_arrow(value)], ' '
      end

      def new_tab_arrow(value)
        tag.a icon_tag(:point_right), href: value, target: '_blank', rel: 'noopener',
                                      class: 'icon-link icon-link-hover',
                                      aria: { label: t('recourse.new_tab') }
      end
    end
  end
end
