module Recourse
  module Helpers
    # How one attribute reads on a page that only reads it.
    module Formats
      # One absolute web address and nothing else: a value to follow, not to read.
      # Anything around it — words, a second address — reads as text instead. What it
      # captures is what a link says: the host, less any `www.`, and whatever follows.
      WEB_URL = %r{\Ahttps?://(?:www\.)?([^/?#\s]+)(\S*)\z}

    private

      # What the record says for one column, formatted by what the column holds.
      def formatted_value(column)
        association = belongs_to_association column
        return named_cell resource_record, association if association

        formatted_attribute column, resource_record.attributes[column]
      end

      # One value, formatted by the kind its column holds — the one ladder a table
      # cell and a show page's value both come down, so a boolean is the same icon
      # and an enum the same badge on either. A block, where the caller has one,
      # marks the search terms inside whichever arm ends up as words.
      def formatted_attribute(column, value, &)
        kind = attribute_kind column
        return listed Array(value) if kind == :list
        return formatted_number kind, column, value if numeric_kind? kind

        formatted_text kind, value, &
      end

      def formatted_number(kind, column, value)
        return uncounted kind, value if Kinds::UNCOUNTED_KINDS.include? kind

        case kind
        when :integer then number_with_delimiter value
        when :phone then number_to_phone value
        when :monetary then number_to_currency value, **precision_option(column)
        when :percentage then number_to_percentage value, **precision_option(column)
        when :decimal then number_with_precision value, **precision_option(column)
        else number_with_precision value
        end
      end

      def formatted_text(kind, value, &)
        case kind
        when :enum then value && enum_badge(marked(value, &))
        when :date, :datetime, :time then value && localized(kind, value)
        when *Kinds::JSON_KINDS then value.presence && json_block(value)
        else linked_or_marked(value, &)
        end
      end

      # One whole web address is a value to follow rather than to read, and anything
      # else is words — which the caller may have marking of its own for.
      def linked_or_marked(value, &)
        web_url?(value) ? url_link(value) : marked(value, &)
      end

      # The caller's own marking, where it has one: a table marks what a search
      # matched, and a show page, which no search reached, has nothing to mark.
      def marked(value, &)
        block_given? ? yield(value) : value
      end

      # A payload read as the JSON it is rather than as the Hash Ruby prints. In a block
      # of its own that scrolls rather than grows: one of these is as tall as a page, and
      # nothing else on a record's page should have to move aside for it. `presence`, so
      # an empty payload reads as the dash every other empty value does.
      def json_block(value)
        tag.pre JSON.pretty_generate(value), class: 'recourse-payload'
      end

      def enum_badge(value)
        tag.span value, class: 'badge'
      end

      def web_url?(value)
        value.is_a?(String) && value.match?(WEB_URL)
      end

      # Bootstrap's icon link, saying the value leads somewhere the way text cannot.
      # What it reads is the host, and an ellipsis where the address goes further --
      # a path is how a machine finds the page, and the href is already carrying it.
      def url_link(value)
        host, rest = value.match(WEB_URL).captures
        said = rest.delete_suffix('/').empty? ? host : "#{host}/…"

        tag.a safe_join([said, icon_tag(:point_right)], ' '),
              href: value, class: 'icon-link icon-link-hover'
      end
    end
  end
end
