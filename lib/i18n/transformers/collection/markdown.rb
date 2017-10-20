module I18n
  module Transformers
    class Collection
      class Markdown < Base
        def initialize(key_pattern: /(\b|_|\.)md$/, adapter: nil, **options, &block)
          super options, &block
          self.key_pattern = key_pattern
          self.adapter = adapter
        end

        def key_pattern=(pattern)
          @key_pattern = pattern.is_a?(Regexp) ? pattern : Regexp.quote(pattern.to_s)
        end

        def adapter=(adptr)
          return unless adptr

          require adptr
          @adapter = adptr
        end

        def transform(key, value)
          return value unless @key_pattern =~ key.to_s

          res = @block ? @block.call(key, value) : markdown_to_html(value)
          res.respond_to?(:html_safe) ? res.html_safe : res
        end

        def adapter
          @adapter ||= begin
            current_adapter = nil
            available_adapters.each do |a|
              begin
                self.adapter = a
                current_adapter = a
                break
              rescue LoadError
                next
              end
            end
            current_adapter
          end
        end

        def available_adapters
          @available_adapters ||= private_methods
            .grep(/^transform_with_(.+)$/) { |m| $~[1].to_s }
        end

        private

        def markdown_to_html(value)
          method = "transform_with_#{adapter}"
          raise "Unknown adapter: #{adapter}" unless respond_to?(method, true)

          send method, value
        end

        def transform_with_redcarpet(value)
          @redcarpet ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, @options)
          @redcarpet.render(value)
        end

        def transform_with_kramdown(value)
          Kramdown::Document.new(value).to_html
        end
      end
    end
  end
end
