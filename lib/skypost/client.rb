require 'faraday'
require 'json'

module Skypost
  class Client
    BASE_URL = "https://bsky.social"
    
    class AuthenticationError < StandardError; end
    class ValidationError < StandardError; end

    def initialize(identifier = nil, password = nil)
      @identifier = identifier
      @password = password
      @session = nil
      validate_identifier if identifier
    end

    def authenticate
      raise AuthenticationError, "Identifier and password are required" if @identifier.nil? || @password.nil?

      response = connection.post("/xrpc/com.atproto.server.createSession") do |req|
        req.headers["Content-Type"] = "application/json"
        req.body = JSON.generate({
          identifier: @identifier,
          password: @password
        })
      end

      @session = JSON.parse(response.body)
      @session
    rescue Faraday::ResourceNotFound => e
      raise AuthenticationError, "Authentication failed: Invalid credentials or incorrect handle format. Your handle should be either your custom domain (e.g., 'username.com') or your Bluesky handle (e.g., 'username.bsky.social')"
    rescue Faraday::Error => e
      raise AuthenticationError, "Failed to authenticate: #{e.message}"
    end

    def post(text)
      ensure_authenticated

      current_time = Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S.%3NZ")
      facets = extract_links(text)
      
      request_body = {
        repo: @session["did"],
        collection: "app.bsky.feed.post",
        record: {
          text: text.gsub(/<a href="[^"]*">|<\/a>/, ''),  # Remove HTML tags but keep link text
          facets: facets,
          createdAt: current_time,
          "$type": "app.bsky.feed.post"
        }
      }

      response = connection.post("/xrpc/com.atproto.repo.createRecord") do |req|
        req.headers["Content-Type"] = "application/json"
        req.headers["Authorization"] = "Bearer #{@session["accessJwt"]}"
        req.body = JSON.generate(request_body)
      end

      JSON.parse(response.body)
    rescue Faraday::ResourceNotFound => e
      raise "Failed to post: The API endpoint returned 404. Please check if you're authenticated and using the correct API endpoint."
    rescue Faraday::Error => e
      raise "Failed to post: #{e.message}"
    end

    private

    def validate_identifier
      unless @identifier.include?(".")
        raise ValidationError, "Invalid handle format. Handle must be either a custom domain (e.g., 'username.com') or a Bluesky handle (e.g., 'username.bsky.social')"
      end
    end

    def ensure_authenticated
      authenticate if @session.nil?
    end

    def connection
      @connection ||= Faraday.new(url: BASE_URL) do |f|
        f.request :json
        f.response :raise_error
      end
    end

    def extract_links(text)
      facets = []
      link_pattern = /<a href="([^"]*)">(.*?)<\/a>/
      
      # First, find all matches to calculate correct byte positions
      matches = text.to_enum(:scan, link_pattern).map { Regexp.last_match }
      plain_text = text.gsub(/<a href="[^"]*">|<\/a>/, '')  # Text with HTML removed
      
      matches.each do |match|
        url = match[1]
        link_text = match[2]
        
        # Find the link text in the plain text to get correct byte positions
        if link_position = plain_text.index(link_text)
          facets << {
            index: {
              byteStart: link_position,
              byteEnd: link_position + link_text.bytesize
            },
            features: [{
              "$type": "app.bsky.richtext.facet#link",
              uri: url
            }]
          }
        end
      end

      facets
    end
  end
end
