require 'securerandom'
require 'json'
require 'uri'
require 'cgi'

require 'excon'
require 'rrrretry'

require 'git_hub_bub/request'
require 'git_hub_bub/response'

module GitHubBub
  class << self
    def head(*args)
      Request.head(*args)
    end

    def get(*args)
      Request.get(*args)
    end

    def post(*args)
      Request.post(*args)
    end

    def put(*args)
      Request.put(*args)
    end

    def patch(*args)
      Request.patch(*args)
    end

    def delete(*args)
      Request.delete(*args)
    end
  end
end