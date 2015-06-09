require 'parser/ruby22'
require 'unparser'

module Rehab
  class ClassyConverter
    def self.convert(source)
      new(source).convert
    end

    def initialize(source)
      @source = source
    end

    # for the prototype, expect:
    # function ..
    #   on ..
    # ..
    def convert
      Unparser.unparse(generate_classes(extract_classes(@source)))
    end

    def extract_classes(source)
      ast = Parser::Ruby22.parse(source)
      classes = {}
      ast.children.each do |top_level|
        if top_level.type == :function
          children = if top_level.children[1].type == :begin
            top_level.children[1].children
          else
            [top_level.children[1]]
          end
          children.each do |child|
            if child.type == :on
              class_label = child.children[0]
              classes[class_label] ||= {}
              classes[class_label][top_level.children[0]] = child.children[1..-1]
            end
          end
        end
      end
      classes
    end

    def generate_classes(classes)
      Parser::AST::Node.new(:begin,
        classes.map(&method(:generate_class)))
    end

    def generate_class((label, functions))
      def_node = if functions.length > 1
        Parser::AST::Node.new(:begin,
          functions.map(&method(:generate_def)))
      else
        generate_def([functions.keys[0], functions.values[0]])
      end
      Parser::AST::Node.new(:class, [label, nil, def_node])
    end

    def generate_def((label, def_))
      Parser::AST::Node.new(:def, [label, def_[0], def_[1]])
    end
  end
end
