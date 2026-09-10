module Recourse
  # Where a write goes once it has landed, and what the page it lands on is told about
  # it. Apart from the actions that write, because the answer is the routes' rather than
  # any one action's: three of them ask it, and none of them decides it.
  module Landing
  private

    # What a write says once it has landed: the message, and the record it landed on
    # where one survives, for the page to mark and lead to while that message stands.
    def wrote(message, record = nil)
      flash.notice = message
      flash[Recourse::WRITTEN] = written record if record
      redirect_to written_url, status: :see_other
    end

    # What the page is told about that record: the row to mark, the words the message
    # calls it by, and its own page where the routes drew one — nil where they did not,
    # so the words stay words. String keys: the flash rides the session as JSON.
    def written(record)
      shown = Recourse.routed? controller_path, 'show'
      url = url_for(action: :show, id: record, only_path: true) if shown

      { 'row' => Recourse.row_id(record), 'label' => Recourse.record_title(record), 'url' => url }
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

    # And where a write goes: the index, or — where the routes drew none — back to the
    # record it hangs off, which for a bare action is the page its button stood on.
    def written_url
      return url_for action: :index if Recourse.routed? controller_path, 'index'

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
