require "http/server"
require "json"

require "./facet/node"
require "./facet/element_ref"
require "./facet/binding"
require "./facet/parser"
require "./facet/compiler"
require "./facet/static_compiler"
require "./facet/context"
require "./facet/renderer"
require "./facet/router"
require "./facet/spa_router"
require "./facet/server"

module Facet
  def self.build(router : Router, port : Int32 = 3000) : Server
    Server.new(router, port)
  end

  def self.run(router : Router, port : Int32 = 3000) : Nil
    server = build(router, port)
    server.start
  end

  def self.compile_static(input_dir : String = ".", output_dir : String = "dist") : Nil
    StaticCompiler.new(input_dir, output_dir).compile
  end
end
