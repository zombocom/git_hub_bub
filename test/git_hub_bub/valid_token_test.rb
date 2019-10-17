require 'test_helper'

class ValidTokenTest < Test::Unit::TestCase
  include WebMock::API

  def teardown
    GitHubBub::Request.clear_callbacks
  end

  def test_does_not_add_token_to_header
    token    = "foo"
    url      = "https://#{ENV['GITHUB_APP_ID']}:#{ENV['GITHUB_APP_SECRET']}@api.github.com/applications/#{ENV['GITHUB_APP_ID']}/tokens/#{token}"
    stub_get = stub_request(:get, url)

    GitHubBub::Request.any_instance.expects(:token).never

    GitHubBub::Request.set_before_callback do |request|
      if request.token?
        # Should be true for this call
      else
        raise "nope"
      end
    end

    GitHubBub.valid_token?(token)
    assert_requested stub_get
  end
end
