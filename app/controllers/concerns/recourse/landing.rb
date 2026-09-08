module Recourse
  # Where a write goes once it has landed, and what the page it lands on is told about
  # it. Apart from the actions that write, because the answer is the routes' rather than
  # any one action's: three of them ask it, and none of them decides it.
  module Landing
  private

    # What a write says once it has landed: the message, and the row it landed on where
    # one survives, for the page to mark while that message stands.
    def wrote(message, record = nil)
      flash.notice = message
      flash[Recourse::WRITTEN] = Recourse.row_id record if record
      redirect_to written_url, status: :see_other
    end

    # What a rejected write does instead: the form again, with the message over it and
    # the errors beside the fields that earned them.
    def rejected(record, page, message)
      return refused record, message unless Recourse.routed? controller_path, page.to_s

      flash.now.alert = message
      render page, status: :unprocessable_entity
    end

    # And where a rejection goes when there is no form to send it back to. A bare
    # action's button stands on a page about something else, so what turned the write
    # down is the whole of what there is to say, said where the button was.
    def refused(record, message)
      flash.alert = record.errors.full_messages.to_sentence.presence || message
      redirect_to written_url, status: :see_other
    end

    # And where a write goes: the index, or the record's own page where the routes drew none
    # — a singular resource is the collection of one. A nesting that routed neither has
    # no page anywhere to land on, so the write goes back to the record it hangs off,
    # which for a bare action is the page its button stood on.
    def written_url
      return url_for action: :index if Recourse.routed? controller_path, 'index'
      return url_for action: :show if Recourse.idless_route? controller_path, 'show'

      parent_url
    end

    # That record's own page. The path is read back from the routes rather than chopped
    # off this controller's own: how many segments the nesting added — a `namespace`
    # among them — is something the routes knew and a path no longer says.
    def parent_url
      url_for controller: "/#{Recourse.parent_of controller_path}", action: :show,
              id: @recourse_parent
    end
  end
end
