require "test_helper"

class ValidTokenTest < Test::Unit::TestCase
  include WebMock::API

  def teardown
    GitHubBub::Request.clear_callbacks
  end

  def test_does_not_add_token_to_header
    # Disable VCR so WebMock's stub_request can handle the request directly
    VCR.turned_off do
      token = "foo"
      url = "https://api.github.com/applications/#{ENV["GITHUB_APP_ID"]}/tokens/#{token}"
      # Add a basic auth header, will fail if `'Authorization'=>'token ...'` header is added by mistake
      stub_get = stub_request(:get, url).with(basic_auth: [ENV["GITHUB_APP_ID"], ENV["GITHUB_APP_SECRET"]])

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
end
