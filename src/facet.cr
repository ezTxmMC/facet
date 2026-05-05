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

command = ARGV[0]?
input_dir = ARGV[1]?
output_dir = ARGV[2]? || "dist"

unless command && input_dir
  STDERR.puts "Usage: facet <command> <input_dir> [output_dir]"
  STDERR.puts ""
  STDERR.puts "Commands:"
  STDERR.puts "  compile    Compile HCR templates to static HTML with hashed assets"
  STDERR.puts ""
  STDERR.puts "Examples:"
  STDERR.puts "  facet compile test/"
  STDERR.puts "  facet compile test/ build/"
  exit 1
end

case command
when "compile"
  unless Dir.exists?(input_dir)
    STDERR.puts "Error: Input directory '#{input_dir}' not found"
    exit 1
  end

  puts "Compiling HCR templates from #{input_dir} → #{output_dir}/"
  compiler = Facet::StaticCompiler.new(input_dir, output_dir)
  compiler.compile

else
  STDERR.puts "Unknown command: #{command}"
  STDERR.puts "Try 'facet --help' for usage information"
  exit 1
end