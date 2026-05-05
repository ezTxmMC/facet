module Facet
  class Context
    getter request : HTTP::Request
    getter response : HTTP::Server::Response
    getter session : Hash(String, String)

    def initialize(@request : HTTP::Request, @response : HTTP::Server::Response)
      @session = {} of String => String
    end

    def logged_in? : Bool
      session.has_key?("user_id")
    end

    def param(key : String) : String?
      request.query_params[key]?
    end

    def json_body : JSON::Any
      JSON.parse(request.body.try(&.gets_to_end) || "{}")
    end
  end
end