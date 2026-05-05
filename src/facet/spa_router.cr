module Facet
  class SPA
    getter app_root : String
    getter protected_routes : Array(String)
    getter routes : Hash(String, String)

    def initialize(@app_root : String)
      @protected_routes = [] of String
      @routes = {} of String => String
    end

    def route(path : String, view : String)
      @routes[path] = view
    end

    def protect(path : String)
      @protected_routes << path
    end

    def build : Router
      router = Router.new

      @routes.each do |path, _view|
        router.get(path) { |ctx| serve_index(ctx) }
      end

      router.get(/^\/views\/.+\.hcr$/) { |ctx| serve_hcr_view(ctx) }

      router.get(/^\/styles\/.+\.css$/) { |ctx| serve_css_file(ctx) }

      router.get(/^\/styles-.+\.css$/) { |ctx| serve_dist_css(ctx) }
      router.get(/^\/index-.+\.js$/) { |ctx| serve_dist_js(ctx) }

      router
    end

    private def serve_index(ctx : Context)
      index_path = File.join(@app_root, "index.html")

      if File.exists?(index_path)
        ctx.response.content_type = "text/html; charset=utf-8"
        ctx.response.print File.read(index_path)
      else
        ctx.response.status = HTTP::Status::NOT_FOUND
        ctx.response.print "index.html not found"
      end
    end

    private def serve_hcr_view(ctx : Context)
      path = ctx.request.path
      file_path = File.join(@app_root, path)

      if File.exists?(file_path)
        content = File.read(file_path)
        cleaned = content.gsub(/\<\?cr\s*[\s\S]*?\?\>/m, "")

        ctx.response.content_type = "text/html; charset=utf-8"
        ctx.response.print cleaned
      else
        ctx.response.status = HTTP::Status::NOT_FOUND
        ctx.response.print "Not found"
      end
    end

    private def serve_css_file(ctx : Context)
      path = ctx.request.path
      file_path = File.join(@app_root, path)

      if File.exists?(file_path)
        ctx.response.content_type = "text/css; charset=utf-8"
        ctx.response.print File.read(file_path)
      else
        ctx.response.status = HTTP::Status::NOT_FOUND
        ctx.response.print "Not found"
      end
    end

    private def serve_dist_css(ctx : Context)
      path = ctx.request.path
      file_path = File.join(@app_root, "dist", path.sub(/^\//, ""))

      if File.exists?(file_path)
        ctx.response.content_type = "text/css; charset=utf-8"
        ctx.response.print File.read(file_path)
      else
        ctx.response.status = HTTP::Status::NOT_FOUND
        ctx.response.print "Not found"
      end
    end

    private def serve_dist_js(ctx : Context)
      path = ctx.request.path
      file_path = File.join(@app_root, "dist", path.sub(/^\//, ""))

      if File.exists?(file_path)
        ctx.response.content_type = "application/javascript; charset=utf-8"
        ctx.response.print File.read(file_path)
      else
        ctx.response.status = HTTP::Status::NOT_FOUND
        ctx.response.print "Not found"
      end
    end
  end
end
