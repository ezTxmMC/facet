module Facet
  class BindingCompiler
    
    def self.compile_to_js(bindings : Array({type: String, selector: String, handler: String})) : String
      return "" if bindings.empty?

      js = String::Builder.new
      js << "<script>\n"
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
      js << "</script>"
      js.to_s
    end

    private def self.build_handler(raw : String) : String
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
  end
end