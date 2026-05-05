require "digest/md5"

module Facet
  class StaticCompiler
    def initialize(@input_dir : String, @output_dir : String)
      @styles = String::Builder.new
      @bindings = [] of {type: String, selector: String, handler: String}
      @pages = {} of String => String
    end

    def compile : Nil
      Dir.mkdir_p(@output_dir)

      hcr_files = Dir.glob("#{@input_dir}/**/*.hcr")

      if hcr_files.empty?
        puts "No .hcr files found in #{@input_dir}"
        return
      end

      hcr_files.each do |hcr_path|
        process_hcr(hcr_path)
      end

      js_content = compile_bindings_to_js(@bindings)

      css_content = @styles.to_s.strip
      unless css_content.empty?
        css_digest = Digest::MD5.digest(css_content).map { |b| b.to_s(16).rjust(2, '0') }.join
        css_hash = css_digest[0...8]
        css_filename = "styles-#{css_hash}.css"
        File.write(File.join(@output_dir, css_filename), css_content)
        puts "  → #{css_filename}"
      end

      unless js_content.empty?
        js_digest = Digest::MD5.digest(js_content).map { |b| b.to_s(16).rjust(2, '0') }.join
        js_hash = js_digest[0...8]
        js_filename = "index-#{js_hash}.js"
        File.write(File.join(@output_dir, js_filename), js_content)
        puts "  → #{js_filename}"
      end

      @pages.each do |page_name, html|
        html_with_refs = insert_asset_refs(html, css_content, js_content)
        File.write(File.join(@output_dir, page_name), html_with_refs)
        puts "  → #{page_name}"
      end

      puts "\nCompiled to #{@output_dir}/"
    end

    private def process_hcr(path : String) : Nil
      content = File.read(path)

      nodes = Facet::Parser.parse(content)

      html_parts = [] of String

      nodes.each do |node|
        case node
        when HtmlNode
          html_parts << node.content
        when CodeNode
          if node.init
            extract_bindings(node.source)
          end
        end
      end

      html_content = html_parts.join

      style_pattern = /<style[^>]*>(.*?)<\/style>/m
      html_content.scan(style_pattern) do |match|
        @styles << match[1] << "\n"
      end

      html_without_styles = html_content.gsub(style_pattern, "")

      page_name = "index.html"
      @pages[page_name] = html_without_styles
    end

    private def extract_bindings(source : String) : Nil
      pattern = /\$\{'([^']+)'\}\.on(\w+)\s*=\s*(\w+)\((.*?)\)/

      source.scan(pattern) do |match|
        selector = match[1]
        event_type = match[2].downcase
        handler = match[3]
        args = match[4]

        @bindings << {
          type: event_type,
          selector: selector,
          handler: "#{handler}(#{args})"
        }
      end
    end

    private def compile_bindings_to_js(bindings : Array({type: String, selector: String, handler: String})) : String
      return "" if bindings.empty?

      js = String::Builder.new
      js << "(function() {\n"
      js << "  function _el(s) { return s.startsWith('#') ? document.getElementById(s.slice(1)) : document.querySelector(s); }\n\n"

      bindings.each do |b|
        target = "_el('#{b[:selector]}')"
        handler_js = build_handler(b[:handler])

        js << "  var _t = #{target};\n"
        js << "  if (_t) _t.addEventListener('#{b[:type]}', function(e) {\n"
        js << "    e.preventDefault();\n"
        js << "    #{handler_js}\n"
        js << "  });\n\n"
      end

      js << "})();\n"
      js.to_s
    end

    private def build_handler(raw : String) : String
      match = raw.match(/^(\w+)\((.*)\)$/)
      return "console.warn('Facet: unknown handler #{raw}');" unless match

      action = match[1]
      args_raw = match[2]

      params = args_raw.split(",").map(&.strip).map do |arg|
        ref = arg.match(/\$\{'([^']+)'\}/)
        if ref
          sel = ref[1]
          key = sel.lstrip('#').lstrip('.')
          "#{key}: _el('#{sel}').value"
        else
          "arg: #{arg}"
        end
      end

      body_obj = "{#{params.join(", ")}}"
      <<-JS
        fetch('/_facet/#{action}', {
          method: 'POST',
          headers: {'Content-Type': 'application/json'},
          body: JSON.stringify(#{body_obj})
        }).then(r => r.json()).then(function(res) {
          if (res.redirect) window.location.href = res.redirect;
          if (res.html) document.body.innerHTML = res.html;
        });
      JS
    end

    private def insert_asset_refs(html : String, css : String, js : String) : String
      result = html

      unless css.empty?
        css_digest = Digest::MD5.digest(css).map { |b| b.to_s(16).rjust(2, '0') }.join
        css_hash = css_digest[0...8]
        css_link = "\n  <link rel=\"stylesheet\" href=\"styles-#{css_hash}.css\">"

        if result.includes?("</head>")
          result = result.sub("</head>", "#{css_link}\n</head>")
        else
          result = "  <head>\n#{css_link}\n  </head>\n" + result
        end
      end

      unless js.empty?
        js_digest = Digest::MD5.digest(js).map { |b| b.to_s(16).rjust(2, '0') }.join
        js_hash = js_digest[0...8]
        script_tag = "\n  <script src=\"index-#{js_hash}.js\"></script>"

        if result.includes?("</body>")
          result = result.sub("</body>", "#{script_tag}\n</body>")
        end
      end

      result
    end
  end
end
