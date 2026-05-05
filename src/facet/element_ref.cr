module Facet
  class ElementRef
    getter selector : String

    def initialize(@selector : String)
    end

    def id : String
      selector.lstrip('#')
    end

    def onclick=(handler : String)
      BindingRegistry.register_click(selector, handler)
    end

    def to_s : String
      selector
    end
  end

  module BindingRegistry
    @@bindings = [] of {type: String, selector: String, handler: String}

    def self.register_click(selector : String, handler : String)
      @@bindings << {type: "click", selector: selector, handler: handler}
    end

    def self.flush : Array({type: String, selector: String, handler: String})
      result = @@bindings.dup
      @@bindings.clear
      result
    end
  end
end