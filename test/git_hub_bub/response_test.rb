require "test_helper"

class ResponseTest < Test::Unit::TestCase
  def test_pagination
    response = GitHubBub::Response.new(rails_issues_data(:first))
    assert_equal({"next_url" => "https://api.github.com/repositories/8514/issues?page=2",
                  "last_url" => "https://api.github.com/repositories/8514/issues?page=18"},
      response.pagination)

    assert_equal "https://api.github.com/repositories/8514/issues?page=2", response.next_url
    assert_equal "https://api.github.com/repositories/8514/issues?page=18", response.last_url
    assert_equal nil, response.prev_url
    assert_equal nil, response.first_url

    refute response.last_page?
    assert response.first_page?

    response = GitHubBub::Response.new(rails_issues_data(:second))
    assert_equal({"next_url" => "https://api.github.com/repositories/8514/issues?page=3",
                  "last_url" => "https://api.github.com/repositories/8514/issues?page=18",
                  "first_url" => "https://api.github.com/repositories/8514/issues?page=1",
                  "prev_url" => "https://api.github.com/repositories/8514/issues?page=1"},
      response.pagination)

    assert_equal "https://api.github.com/repositories/8514/issues?page=3", response.next_url
    assert_equal "https://api.github.com/repositories/8514/issues?page=18", response.last_url
    assert_equal "https://api.github.com/repositories/8514/issues?page=1", response.prev_url
    assert_equal "https://api.github.com/repositories/8514/issues?page=1", response.first_url

    refute response.last_page?
    refute response.first_page?

    response = GitHubBub::Response.new(rails_issues_data(:last))
    assert_equal({"last_url" => "https://api.github.com/repositories/8514/issues?page=1",
                  "first_url" => "https://api.github.com/repositories/8514/issues?page=1",
                  "prev_url" => "https://api.github.com/repositories/8514/issues?page=17"},
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

  def test_rate_limit_reset_time_left
    epoch_time = 1504196685
    Timecop.freeze(Time.at(epoch_time).to_datetime) do
      response = GitHubBub::Response.new(rails_issues_data(:last))
      assert_equal 0, response.rate_limit_reset_time_left
    end

    Timecop.freeze(Time.at(epoch_time - 2).to_datetime) do
      response = GitHubBub::Response.new(rails_issues_data(:last))
      assert_equal 2, response.rate_limit_reset_time_left
    end
  end

  def test_last_page_with_next_but_no_last_url
    # This reproduces a real response from the GitHub API where the Link header
    # only contains rel="next" but no rel="last"
    data = {
      body: "[{\"url\":\"https://api.github.com/repos/puma/puma/issues/3643\"}]",
      headers: {
        "Link" => "<https://api.github.com/repositories/2441517/issues?direction=desc&page=2&sort=comments&state=open&after=Y3Vyc29yOnYyOpIIzpU4Fek%3D&per_page=30>; rel=\"next\""
      },
      status: 200
    }
    response = GitHubBub::Response.new(data)

    assert_equal "https://api.github.com/repositories/2441517/issues?direction=desc&page=2&sort=comments&state=open&after=Y3Vyc29yOnYyOpIIzpU4Fek%3D&per_page=30",
      response.next_url
    assert_nil response.last_url

    refute response.last_page?
  end

  def test_rate_limit_sleep
    epoch_time = 1504196685

    # We are equal to our rate limit offset time
    Timecop.freeze(Time.at(epoch_time).to_datetime) do
      response = GitHubBub::Response.new(rails_issues_data(:last))
      assert_equal 0, response.rate_limit_sleep!(bypass_sleep: true)
    end

    # We are beyond our rate limit offset time
    Timecop.freeze(Time.at(epoch_time + 1).to_datetime) do
      response = GitHubBub::Response.new(rails_issues_data(:last))
      assert_equal 0, response.rate_limit_sleep!(bypass_sleep: true)
    end

    # We have lots of requests
    Timecop.freeze(Time.at(epoch_time - 1).to_datetime) do
      response = GitHubBub::Response.new(rails_issues_data(:last))
      response.headers["X-RateLimit-Limit"] = "5000"
      assert_equal 0, response.rate_limit_sleep!(bypass_sleep: true)
    end

    # We have limits zero remaining, and are 1 second away from reset
    Timecop.freeze(Time.at(epoch_time - 1).to_datetime) do
      response = GitHubBub::Response.new(rails_issues_data(:last))
      response.headers["X-RateLimit-Limit"] = "0"
      assert_equal 1, response.rate_limit_sleep!(bypass_sleep: true)
    end

    # We have 10 requests remaining and are 1 second away from reset
    Timecop.freeze(Time.at(epoch_time - 1).to_datetime) do
      response = GitHubBub::Response.new(rails_issues_data(:last))
      response.headers["X-RateLimit-Limit"] = "10"
      assert_equal 1.0 / 10, response.rate_limit_sleep!(bypass_sleep: true)
    end
  end
end
