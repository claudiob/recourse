require 'action_dispatch/testing/integration'

# What every test that visits a page needs, said once. `Minitest::Test` rather than
# `ActiveSupport::TestCase` on purpose: this suite runs without the on_load hooks
# that one fires, which is what `test_helper` swaps the Turbo debouncer for.
class IntegrationCase < Minitest::Test
  def setup
    @session = ActionDispatch::Integration::Session.new Rails.application
    @session.host! 'localhost'
  end

  # The page at `path`, which is expected to be there: a test asserting markup has
  # nothing to say about a 404, so the status is checked here rather than in each.
  def visit(path)
    @session.get path

    assert_equal 200, @session.response.status, "GET #{path}"
    body
  end

  # What the last request answered.
  def body = @session.response.body

  # Where a write sent the browser next, which is expected to say what was done.
  def follow_and_assert_flash(message)
    @session.follow_redirect!

    assert_includes body, message
  end

  # The SQL one block issued against one table, so a test can count what a page
  # costs — which no covered line can stand in for.
  def queries_on(table, &)
    sql_matching %(FROM "#{table}"), &
  end

  # And the same for what a block wrote, which names its table without a `FROM`:
  # a shift written a row at a time costs a statement each, and only a count says so.
  def writes_on(table, &)
    sql_matching %(UPDATE "#{table}"), &
  end

private

  def sql_matching(fragment)
    queries = []
    subscription = ActiveSupport::Notifications.subscribe 'sql.active_record' do |*, payload|
      queries << payload[:sql] if payload[:sql].include? fragment
    end
    yield
    queries
  ensure
    ActiveSupport::Notifications.unsubscribe subscription
  end
end
