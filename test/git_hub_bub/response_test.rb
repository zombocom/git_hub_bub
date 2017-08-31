require 'test_helper'

class ResponseTest < Test::Unit::TestCase

  def test_pagination
    response = GitHubBub::Response.new(rails_issues_data(:first))
    assert_equal({"next_url"=>"https://api.github.com/repositories/8514/issues?page=2",
                  "last_url"=>"https://api.github.com/repositories/8514/issues?page=18"},
                  response.pagination)


    assert_equal "https://api.github.com/repositories/8514/issues?page=2", response.next_url
    assert_equal "https://api.github.com/repositories/8514/issues?page=18", response.last_url
    assert_equal nil, response.prev_url
    assert_equal nil, response.first_url

    refute response.last_page?
    assert response.first_page?

    response = GitHubBub::Response.new(rails_issues_data(:second))
    assert_equal({"next_url"=>"https://api.github.com/repositories/8514/issues?page=3",
                  "last_url"=>"https://api.github.com/repositories/8514/issues?page=18",
                  "first_url"=>"https://api.github.com/repositories/8514/issues?page=1",
                  "prev_url"=>"https://api.github.com/repositories/8514/issues?page=1"},
                  response.pagination)

    assert_equal "https://api.github.com/repositories/8514/issues?page=3", response.next_url
    assert_equal "https://api.github.com/repositories/8514/issues?page=18", response.last_url
    assert_equal "https://api.github.com/repositories/8514/issues?page=1", response.prev_url
    assert_equal "https://api.github.com/repositories/8514/issues?page=1", response.first_url


    refute response.last_page?
    refute response.first_page?

    response = GitHubBub::Response.new(rails_issues_data(:last))
    assert_equal({"last_url"=>"https://api.github.com/repositories/8514/issues?page=1",
                  "first_url"=>"https://api.github.com/repositories/8514/issues?page=1",
                  "prev_url"=>"https://api.github.com/repositories/8514/issues?page=17"},
                  response.pagination)

    assert_equal nil, response.next_url
    assert_equal "https://api.github.com/repositories/8514/issues?page=1", response.last_url
    assert_equal "https://api.github.com/repositories/8514/issues?page=1", response.first_url
    assert_equal "https://api.github.com/repositories/8514/issues?page=17", response.prev_url

    assert response.last_page?
    refute response.first_page?
  end

  def test_rate_limit_remaining
    response = GitHubBub::Response.new(rails_issues_data(:last))
    assert_equal 60, response.rate_limit_remaining
  end
end