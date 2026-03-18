require "test_helper"

class IndexTest < ActionDispatch::IntegrationTest
  test 'renders a paragraph for a model with no data' do
    get users_url

    assert_select 'h2', text: 'Users'
    assert_select 'p', text: 'No users.'
  end

  test 'renders a link to Add if the :new action is included' do
    get users_url

    assert_select 'a', text: 'Add user'
  end

  test 'renders a table with the ID of each record for a model with some data' do
    get fans_url

    assert_select 'h2', text: 'Fans'
    assert_select 'th[scope=col]', text: 'ID'
    assert_select 'td', text: fans(:first).id.to_s
    assert_select 'span.pagy.info', text: 'Displaying 1 item'
  end

  test 'uses the _row.html.erb partial to display a custom set of columns if present' do
    get babies_url

    assert_select 'h2', text: 'Babies'
    assert_select 'th[scope=col]', text: 'Age'
    assert_select 'td', text: babies(:first).age.to_s
  end

  test 'renders a search form if the model is searchable' do
    get posts_url

    assert_select 'h2', text: 'Posts'
    assert_select 'input[type=search]'
  end

  test 'highlights the search result when search_highlight is used' do
    get posts_url q: { content_cont: 'usehol' }

    assert_includes response.body, 'Two ho<mark>usehol</mark>ds'
  end

  test 'renders a filter dropdown if the model is filterable' do
    get tasks_url

    assert_select 'option', text: 'Running'
    assert_select 'option', text: 'Stopped'
  end
end
