require 'test_helper'
require 'integration_case'

# The form `new` and `edit` draw, and the rules each field carries into the browser.
class TestRecoursesForm < IntegrationCase
  # One pass over a form whose model has a column of every kind. Every rule here is
  # read off a validator rather than off the schema: a length becomes `maxlength`, a
  # format becomes `pattern`, a numericality becomes a numeric keyboard and a step,
  # and a column with no validator saying otherwise is simply optional.
  def test_each_field_carries_the_rules_its_own_validators_state
    visit "/places/#{Place.order(:id).first.id}/edit"

    # An integer steps by one; a float by anything; a decimal by its own scale, and
    # stops at what its precision can hold.
    assert_includes body, 'inputmode="numeric" required="required" step="1" type="number"'
    assert_includes body, 'step="any" type="number"'
    assert_includes body, 'step="0.01" max="999999.99"'
    # Money and a percentage are decimals of their own precision, so their own max.
    assert_includes body, 'max="99999999.99"'
    assert_includes body, 'max="99.99"'
    # A month and a year are counted in no smaller unit than themselves, so each takes
    # the whole-number step an integer does rather than the `any` a decimal admits.
    assert_includes body, 'name="place[busiest_month]"'
    assert_equal 3, body.scan('step="1" type="number"').size
    # A format validator with no sample to show says the pattern itself.
    assert_includes body, 'pattern="[a-z0-9]+(-[a-z0-9]+)*"'
    # And one with a sample says the sample instead.
    assert_includes body, 'title="Please match the format 555-555-5555"'
    assert_includes body, 'type="date"'
    assert_includes body, 'type="datetime-local"'
    # A text column is a textarea, and an optional field says so where it stands.
    assert_includes body, '<textarea class="form-control" placeholder="Optional"'
    # A non-null boolean is a checkbox with the hidden zero beside it.
    assert_includes body, '<input name="place[active]" type="hidden" value="0" />'
    # And a typed reference opens on the record's own label, so an edit that
    # changes something else does not have to retype this one to save.
    assert_includes body, %(value="#{Place.order(:id).first.zip.code}")
    # What the column is for, under the field that sets it — said by the model here,
    # since SQLite keeps no column comments for the schema to have said it.
    assert_includes body, '<div class="form-text mt-1 fg-secondary" ' \
                          'id="place_capacity_help">How many people fit at once</div>'
    assert_equal 1, body.scan('How many people fit at once').size
    # And every control points at its own note, which each kind is told a different
    # way: a box takes it among its other options, a checkbox is handed it on its own
    # because the rest of that hash is no use to one, a menu carries it as a local, and
    # a typed key builds the attribute itself.
    %w[capacity active status zip_id].each do |column|
      assert_includes body, %(aria-describedby="place_#{column}_help")
    end
    # A list is typed one value to a line, and reads back the same way: a box left to
    # fetch an Array for itself would print the brackets.
    # The leading newline is Rails': a browser strips one from inside a `<textarea>`,
    # so the helper writes one to keep a value that genuinely starts blank.
    assert_includes body, %(rows="3" name="place[tags]" id="place_tags">) +
                          %(\nRiverside\nTerrace\nWheelchair access</textarea>)
  end
end
