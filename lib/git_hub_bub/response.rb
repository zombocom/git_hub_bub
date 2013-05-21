module GitHubBub
  class Response < Excon::Response

     def self.create(response)
       self.new(response.data)
     end

     def json_body
      ::JSON.parse(self.body)
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