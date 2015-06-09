require 'parser/ruby22'
require 'unparser'

module Rehab
  class FunkyConverter
    def self.convert(source)
      new(source).convert
    end

    def initialize(source)
      @source = source
    end

    # for the prototype, expect:
    # class ...
    #   def ...
    # ...
    def convert
      Unparser.unparse(generate_functions(extract_functions(@source)))
    end

    def extract_functions(source)
      ast = Parser::Ruby22.parse(source)
      functions = {}
      ast.children.each do |top_level|
        if top_level.type == :class
          children = if top_level.children[2].type == :begin
            top_level.children[2].children
          else
            [top_level.children[2]]
          end
          children.each do |child|
            if child.type == :def
              def_label = child.children[0]
              functions[def_label] ||= {}
              functions[def_label][top_level.children[0].children[1]] = child.children[1..-1]
            end
          end
        end
      end
      functions
    end

    def generate_functions(functions)
      Parser::AST::Node.new(:begin,
        functions.map(&method(:generate_function)))
    end

    def generate_function((label, classes))
      on_node = if classes.length > 1
        Parser::AST::Node.new(:begin,
          classes.map(&method(:generate_on)))
      else
        generate_on([classes.keys[0], classes.values[0]])
      end
      Parser::AST::Node.new(:function, [label, on_node])
    end

    def generate_on((label, on))
      Parser::AST::Node.new(:on, [Parser::AST::Node.new(:const, [nil, label]),
        on[0], on[1]])
    end
  end
end
