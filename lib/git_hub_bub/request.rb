module GitHubBub
  class RequestError < StandardError; end

  class Request
    attr_accessor :url, :options, :token
    BASE_URI       = 'https://api.github.com'
    USER_AGENT     ||= SecureRandom.hex(16)
    GITHUB_VERSION = "vnd.github.3.raw+json"
    EXTRA_HEADERS  ||= {}
    BASE_HEADERS   = EXTRA_HEADERS.merge({'Accept' => "application/#{GITHUB_VERSION}", "User-Agent" => USER_AGENT})
    BASE_OPTIONS   = { omit_default_port:  true }
    RETRIES        = 1

    def initialize(url, query = {}, options = {})
      self.url               = url =~ /^http(\w?)\:\/\// ? url : File.join(BASE_URI, url)
      self.options           = BASE_OPTIONS.merge(options || {})
      self.options[:query]   = query   if query && !query.empty?
      self.options[:headers] = BASE_HEADERS.merge(options[:headers]|| {})
    end

    def self.head(url, query = {}, options = {})
      self.new(url, query, options).head
    end

    def head
      wrap_request do
        Excon.head(url, options)
      end
    end

    def self.get(url, query = {}, options = {})
      self.new(url, query, options).get
    end

    def get
      wrap_request do
        ex = Excon.get(url, options)
        ex = Excon.get(@location, options) if @location = ex.headers["Location"]
        ex
      end
    end

    def self.post(url, query = {}, options = {})
      self.new(url, query, options).post
    end

    def post
      wrap_request do
        Excon.post(url, options)
      end
    end

    def self.patch(url, query = {}, options = {})
      self.new(url, query, options).patch
    end

    def patch
      wrap_request do
        Excon.patch(url, options)
      end
    end

    def self.put(url, query = {}, options = {})
      self.new(url, query, options).put
    end

    def put
      wrap_request do
        Excon.put(url, options)
      end
    end

    def self.delete(url, query = {}, options = {})
      self.new(url, query, options).delete
    end

    def delete
      wrap_request do
        Excon.delete(url, options)
      end
    end

    def wrap_request(&block)
      before_callbacks!
      set_auth_from_token!
      query_to_json_body!
      response = RETRIES.times.retry do
        GitHubBub::Response.create(yield)
      end
      raise RequestError, "message: '#{response.json_body['message']}', url: '#{url}', response: '#{response.inspect}'" unless response.status.to_s =~ /^2.*/
      return response
    end

    # do they take query params? do they take :body?
    # who cares, send them both!
    def query_to_json_body!
      options[:body] = options[:query].to_json if options[:query]
    end

    def set_auth_from_token!
      return unless token
      options[:headers]["Authorization"] ||= "token #{token}"
    end

    def token
      @token ||= if options[:headers] && token_string = options[:headers]["Authorization"]
        token_string.split(/\s/).last
      elsif options[:query] && token = options[:query].delete(:token)
        token
      else
        nil
      end
    end
    alias :token? :token

    def self.set_before_callback(&block)
      before_callbacks << block
    end

    def self.before_callbacks
      @before_callbacks ||=[]
    end

    def self.clear_callbacks
      @before_callbacks = []
    end

    def before_callbacks!
      self.class.before_callbacks.each do |callback|
        run_callback &callback
      end
    end

    def run_callback(&block)
      yield self
    end
  end
end
