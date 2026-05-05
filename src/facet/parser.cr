module Facet
  class Parser
    OPEN_TAG    = "<?cr"
    CLOSE_TAG   = "?>"
    ELEMENT_REF = /\$\{'([^']+)'\}/

    def self.parse(source : String) : Array(Node)
        nodes = [] of Node
        pos = 0
        first_code = true

        while pos < source.size
            open = source.index(OPEN_TAG, pos)

            if open.nil?
                nodes << HtmlNode.new(source[pos..])
                break
            end

            nodes << HtmlNode.new(source[pos...open]) if open > pos

            close = source.index(CLOSE_TAG, open + OPEN_TAG.size)
            raise "Unclosed <?cr block at position #{open}" if close.nil?

            code = source[open + OPEN_TAG.size...close].strip
            html_pos = source.index("<html") || source.size
            nodes << CodeNode.new(code, init: first_code && open < html_pos)
            first_code = false
            pos = close + CLOSE_TAG.size
        end

        nodes
    end
  end
end