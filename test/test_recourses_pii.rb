require 'test_helper'
require 'integration_case'

# A model labelled by an encrypted column, which none of the dummy's own are: `places`
# has no inheritance column, so this is that table read under another name.
class SecretivePlace < Place
  def self.recourse_label = :notes
end

# Where an encrypted column reaches a page and where it does not. Exempt from "as few
# tests as coverage needs": the same lines run whether a value is masked or printed,
# so a covered line cannot stand in for any of these three.
class TestRecoursesPii < IntegrationCase
  # The column list is the single place PII is dropped, and it asks the model rather
  # than a record — so no row's contents can put an encrypted column back. Asked
  # through a template, which is the only thing that asks it: the helper answers to
  # a view rather than to a caller outside one.
  def test_the_generic_columns_leave_out_every_encrypted_attribute
    view = Admin::PlacesController.new.view_context
    columns = view.render(inline: '<%= resource_columns.join " " %>').split

    assert_includes columns, 'name'
    %w[secret notes].each { |column| refute_includes columns, column }
  end

  # And nothing else puts one back either: not a table, whose cells come from that
  # list, and not the search box above it, which looks through what it may read.
  def test_no_encrypted_value_reaches_a_table
    visit '/places'

    ['SEC-0000', 'Private note 1.'].each { |value| refute_includes body, value }
  end

  # The record's own page is the exception, and a deliberate one: this is an admin
  # tool, so reading a record's PII is part of the job. What is not allowed is
  # disclosing it to whoever is behind the person reading, so it arrives masked —
  # one asterisk per character, the plaintext only in an attribute for the reveal to
  # swap in, and nowhere a screenshot would show it.
  def test_the_show_page_masks_an_encrypted_value_until_it_is_asked_for
    visit "/places/#{Place.order(:id).first.id}"

    assert_includes body, '<span data-reveal-target="mask">********</span>'
    assert_includes body, 'data-reveal-plain-value="SEC-0000"'
    refute_includes body, '>SEC-0000<'
  end

  # And a label the search could never match is not one to build a term from. The type
  # says nothing here — encryption leaves a column's type alone — so it is the
  # allowlist that answers: a `cont` against ciphertext matches nothing, and Ransack
  # refuses the reader the box asks for rather than running it, which is a 500 on every
  # index that reaches this model through a foreign key.
  def test_an_encrypted_label_is_not_a_searchable_one
    assert Place.recourse_searchable_label?
    refute SecretivePlace.recourse_searchable_label?
  end

  # The form is the other way round again: an encrypted value arrives in the clear,
  # in the field its kind earns rather than a password box. Editing one record is
  # already a deliberate act; the mask is for the page that only reads.
  def test_the_edit_form_prefills_an_encrypted_field_in_the_clear
    visit "/places/#{Place.order(:id).first.id}/edit"
    field = body[/<input[^>]*name="place\[secret\]"[^>]*>/]

    assert_includes field, 'type="text"'
    assert_includes field, 'value="SEC-0000"'
  end
end
