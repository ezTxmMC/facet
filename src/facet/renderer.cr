module Facet
  module Templates
  end

  class Renderer

    def self.render(nodes : Array(Node), context : Context) : String
      output = String::Builder.new
      js_bindings = ""

      nodes.each do |node|
        case node

        when HtmlNode
          output << node.content

        when CodeNode
          raise "Cannot eval CodeNode at runtime. Compile template first with Facet::Compiler."
        end
      end

      html = output.to_s
      html = html.sub("</body>", "#{js_bindings}\n</body>") unless js_bindings.empty?
      html
    end

    def self.render(template_name : String, context : Context) : String
      dist_path = "dist/index.html"
      if File.exists?(dist_path)
        return File.read(dist_path)
      end

      template_path = "views/#{template_name}.hcr"
      if File.exists?(template_path)
        content = File.read(template_path)
        parser = Parser.new(content)
        nodes = parser.parse
        return render(nodes, context)
      end

      raise "Template not found: #{template_name}"
    end
  end
end