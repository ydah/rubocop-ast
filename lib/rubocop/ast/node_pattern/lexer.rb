# frozen_string_literal: true

begin
  require_relative 'lexer.rex'
rescue LoadError
  msg = '*** You must run `rake generate` to generate the lexer and the parser ***'
  puts '*' * msg.length, msg, '*' * msg.length
  raise
end

module RuboCop
  module AST
    class NodePattern
      # Lexer class for `NodePattern`
      #
      # Doc on how this fits in the compiling process:
      #   /doc/modules/ROOT/pages/node_pattern.md
      class Lexer < LexerRex
        Error = ScanError

        REGEXP_OPTIONS = {
          'i' => ::Regexp::IGNORECASE,
          'm' => ::Regexp::MULTILINE,
          'x' => ::Regexp::EXTENDED,
          'o' => 0
        }.freeze
        private_constant :REGEXP_OPTIONS

        attr_reader :source_buffer, :comments, :tokens

        def initialize(source)
          @tokens = []
          super()
          parse(source)
        end

        private

        # @return [token]
        def emit(type)
          value = ss.captures.first || ss.matched
          value = yield value if block_given?
          token = token(type, value)
          @tokens << token
          token
        end

        def emit_comment
          nil
        end

        def emit_regexp
          body, options = ss.captures
          flag = options.each_char.map { |c| REGEXP_OPTIONS[c] }.sum

          emit(:tREGEXP) { Regexp.new(body, flag) }
        end

        def do_parse
          # Called by the generated `parse` method, do nothing here.
        end

        def token(type, value)
          [type, value]
        end
      end
    end
  end
end
