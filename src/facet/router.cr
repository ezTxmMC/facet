module Facet
  alias Handler = Context -> Nil

  class Router
    getter routes = {} of String => Handler
    getter pattern_routes = [] of {method: String, pattern: Regex, handler: Handler}

    def get(path : String, &block : Handler)
      routes["GET:#{path}"] = block
    end

    def get(pattern : Regex, &block : Handler)
      pattern_routes << {method: "GET", pattern: pattern, handler: block}
    end

    def post(path : String, &block : Handler)
      routes["POST:#{path}"] = block
    end

    def post(pattern : Regex, &block : Handler)
      pattern_routes << {method: "POST", pattern: pattern, handler: block}
    end

    def template(path : String, template_name : String)
      routes["GET:#{path}"] = ->(ctx : Context) {
        html = Renderer.render(template_name, ctx)
        ctx.response.content_type = "text/html"
        ctx.response.print html
      }
    end

    def match(method : String, path : String) : Handler?
      if handler = routes["#{method.upcase}:#{path}"]?
        return handler
      end

      pattern_routes.each do |route|
        if route[:method] == method.upcase && path.match(route[:pattern])
          return route[:handler]
        end
      end

      nil
    end
  end
end