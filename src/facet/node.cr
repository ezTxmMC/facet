module Facet
  abstract class Node
  end

  class HtmlNode < Node
    getter content : String

    def initialize(@content : String)
    end
  end

  class CodeNode < Node
    getter source : String
    getter init : Bool

    def initialize(@source : String, @init : Bool = false)
    end
  end
end