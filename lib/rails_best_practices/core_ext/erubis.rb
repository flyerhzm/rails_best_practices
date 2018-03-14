# encoding: utf-8
# frozen_string_literal: true

require 'erubis'

module Erubis
  class OnlyRuby < Eruby
    def add_preamble(src); end

    def add_text(src, text)
      src << text.gsub(/[^\s;]/, '')
    end

    def add_stmt(src, code)
      src << code
      src << ';'
    end

    def add_expr_literal(src, code)
      src << code
      src << ';'
    end

    def add_expr_escaped(src, code)
      src << code
      src << ';'
    end

    def add_expr_debug(src, code)
      src << code
      src << ';'
    end

    def add_postamble(src); end
  end
end
