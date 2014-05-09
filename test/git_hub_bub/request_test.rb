require 'test_helper'

class RequestTest < Test::Unit::TestCase

  def teardown
    GitHubBub::Request.clear_callbacks
  end

  def test_set_url
    request = GitHubBub::Request.new('foo')
    assert_equal "https://api.github.com/foo", request.url
    request = GitHubBub::Request.new('http://foo.com')
    assert_equal "http://foo.com", request.url
    request = GitHubBub::Request.new('https://bar.com')
    assert_equal "https://bar.com", request.url
    request = GitHubBub::Request.new('arthurnn/http')
    assert_equal "https://api.github.com/arthurnn/http", request.url
    request = GitHubBub::Request.new('arthurnn/https')
    assert_equal "https://api.github.com/arthurnn/https", request.url
  end

  def test_set_callback
    request = GitHubBub::Request.new('foo')

    GitHubBub::Request.set_before_callback do |request|
      request.url = 'bar'
    end

    request.before_callbacks!

    assert_equal 'bar', request.url
  end

  def test_token_parse
    request = GitHubBub::Request.new('foo', token: "foo", what: "yeah")
    request.set_auth_from_token!
    assert_equal "token foo", request.options[:headers]['Authorization']
    assert_equal nil, request.options[:token]
  end

  def test_head_issues
    VCR.use_cassette('HEAD rails/rails/issues') do
      response = GitHubBub.head('/repos/rails/rails/issues')
      assert_equal "GitHub.com", response.headers['Server']
    end
  end

  def test_get_issues
    VCR.use_cassette('GET rails/rails/issues') do
      response = GitHubBub.get('/repos/rails/rails/issues')
      assert_equal 'https://api.github.com/repos/rails/rails/issues/10715', response.json_body.first['url']
    end

    VCR.use_cassette('GET rails/rails/issues?page=2') do
      response = GitHubBub.get('/repos/rails/rails/issues', page: 2)
      assert_equal 'https://api.github.com/repos/rails/rails/issues/10664', response.json_body.first['url']
    end
  end

  def test_post_issues
    VCR.use_cassette('POST /:owner/:repo/issues') do
      params = { title: "Testing",
                 body:  "a gem called git_hub_bub",
                 token: ENV['GITHUB_API_KEY']}
      response = GitHubBub.post("/repos/#{ENV['OWNER']}/#{ENV['REPO']}/issues", params)
      assert_equal "https://api.github.com/repos/#{ENV['OWNER']}/#{ENV['REPO']}/issues/77", response.json_body['url']
      assert_equal params[:title], response.json_body['title']
    end
  end

  def test_patch
    VCR.use_cassette('PATCH user') do
      params = { name:  ENV['USER_NAME'],
                 token: ENV['GITHUB_API_KEY']}
      response = GitHubBub.post('user', params)
      assert_equal params[:name], response.json_body['name']
      assert_equal ENV['OWNER'], response.json_body['login']
    end
  end

  # http://developer.github.com/v3/activity/watching/
  def test_put
    VCR.use_cassette('PUT /repos/:owner/:repo/subscription') do
      subscribed = true
      ignored    = false
      response = GitHubBub.put("/repos/#{ENV['WATCH_OWNER']}/#{ENV['WATCH_REPO']}/subscription", subscribed: subscribed, ignored: ignored, token: ENV['GITHUB_API_KEY'])
      assert_equal 200, response.status
      assert_equal ignored, response.json_body['ignored']
      assert_equal subscribed, response.json_body['subscribed']
    end
  end

  def test_delete
    VCR.use_cassette('DELETE milestone') do
      name = 'test'
      response = GitHubBub.post("repos/#{ENV['OWNER']}/#{ENV['REPO']}/labels", name: name, color: 'FFFFFF', token: ENV['GITHUB_API_KEY'])
      response = GitHubBub.delete("repos/#{ENV['OWNER']}/#{ENV['REPO']}/labels/#{name}", token: ENV['GITHUB_API_KEY'])
      assert_equal 204, response.status
    end
  end
end
