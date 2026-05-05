module Facet
  class Server

    def initialize(@router : Router, @port : Int32 = 3000)
    end

    def start
      server = HTTP::Server.new do |http_ctx|
        ctx = Context.new(http_ctx.request, http_ctx.response)
        handler = @router.match(http_ctx.request.method, http_ctx.request.path)

        if handler
          handler.call(ctx)
        else
          http_ctx.response.status = HTTP::Status::NOT_FOUND
          http_ctx.response.print "404 Not Found"
        end
      end

      puts "Facet server running on http://localhost:#{@port}"
      server.listen("0.0.0.0", @port)
    end
  end
end