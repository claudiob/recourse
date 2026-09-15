module Recourse
  # The files a form submits, which are written after the record rather than with it.
  # An attachment row points at an id, and a record being created has none until it is
  # saved — so a write here is always two steps where a column's is one.
  module AttachmentWriting
    extend ActiveSupport::Concern

  private

    # A new record, then the files that came with it, in one transaction: a record
    # half-saved is worse than one not saved.
    def create_resource(record)
      record.transaction { super && attach_submitted_files(record) }
    end

    # The same for one that already exists.
    def update_resource(record)
      super && attach_submitted_files(record)
    end

    # On a page of what a record has attached, the row between the two goes and the
    # file stays for whatever else points at it; everywhere else the record itself goes.
    def destroy_resource(record)
      return super unless attachment_reflection

      attachment_of(record).destroy!
    end

    # Attached rather than assigned, which is the whole reason this exists. Rails'
    # generated writer replaces every attachment rather than adding to them, and reads
    # a blank field as an instruction to delete the lot — so an edit that touched only
    # a name would purge what the record had. `Attached::Many#attach` appends and
    # `Attached::One#attach` replaces the one, which is what each means on a form.
    #
    # `each` answers the list it was given, which is truthy even when it is empty — so
    # a model with nothing attached never turns a save that worked into a failure.
    def attach_submitted_files(record)
      Recourse.attachment_names(resource_class).each do |name|
        files = submitted_files name
        attached(record, name).attach(*files) if files.present?
      end
    end

    # Built rather than read off the record: the reader Active Storage generates is
    # reachable only by its own name, and this is the object that reader returns.
    def attached(record, name)
      return ActiveStorage::Attached::Many.new name, record if
        Recourse.attachment_many? resource_class, name

      ActiveStorage::Attached::One.new name, record
    end

    # What the form sent for one attachment, as a list either way. Blanks are dropped
    # rather than trusted: the browser sends an empty file input as an empty string,
    # and Active Storage would read a list of those as `delete everything`.
    def submitted_files(name)
      Array(params.dig(controller_name.singularize.to_sym, name)).compact_blank
    end

    # What a form may submit for one: a list of files where the model keeps several,
    # and one file where it keeps one. Permitted alongside the columns, so a host
    # running `action_on_unpermitted_parameters` at `:raise` is not tripped by a field
    # the gem itself drew — and dropped again before anything reaches the record.
    def attachment_filters
      Recourse.attachment_names(resource_class).map do |name|
        Recourse.attachment_many?(resource_class, name) ? { name => [] } : name
      end
    end
  end
end
