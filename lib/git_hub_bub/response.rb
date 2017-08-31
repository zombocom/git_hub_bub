require 'date'

module GitHubBub
  class Response < Excon::Response
     def self.create(response)
       self.new(response.data)
     end

     def rate_limit_remaining
       limit_remaining = headers["X-RateLimit-Limit"]
       Integer(limit_remaining)
     end

     def rate_limit_reset_time_left # in seconds
       utc_epoch_seconds = headers["X-RateLimit-Reset"]
       utc_epoch_seconds = Integer(utc_epoch_seconds)
       return utc_epoch_seconds - Time.now.utc.to_i
     end

     # When no time is left we want to sleep until our limit is reset
     # i.e. remaining is 1 so time/1 => time
     #
     # When we have plenty of requests left then we want to sleep for too long
     # i.e. time / 1000 => smaller amount of time
     def rate_limit_sleep!(bypass_sleep: false)
      remaining = rate_limit_remaining
      time_left = rate_limit_reset_time_left
      return 0 if time_left <= 0
      return 0 if remaining > 1000

      if remaining > 0
        val = time_left / remaining.to_f
      else
        val = time_left
      end
      sleep(val) unless bypass_sleep
      return val
     end

     def json_body
      ::JSON.parse(self.body)
     end

     def success?
      status.to_s =~ /^2.*/
     end

     def pagination
       @pagination ||= parse_pagination
     end

     def parsed_response
      response.body.inspect
     end

     def next_url
       pagination['next_url']
     end

     def prev_url
       pagination['prev_url']
     end
     alias :previous_url :prev_url

     def last_url
       pagination['last_url']
     end

     def first_url
       pagination['first_url']
     end

     def last_page?
       return true if next_url.nil?
       last_page_number = page_number_from_url(last_url)
       next_page_number = page_number_from_url(next_url)
       return next_page_number > last_page_number
     end

     def first_page?
       return true if first_url.nil?
       return false
     end

     def page_number_from_url(url)
       query = ::URI.parse(url).query
       ::CGI.parse(query)["page"].first.to_i
     end

    def header_links
       (headers['link'] || headers['Link'] || "").split(',')
     end

     def parse_pagination
       header_links.each_with_object({}) do |element, hash|
         key   = element[/rel=["'](.*)['"]/, 1]
         value = element[/<(.*)>/, 1]
         hash["#{key}_url"] = value
       end
     end
   end
end