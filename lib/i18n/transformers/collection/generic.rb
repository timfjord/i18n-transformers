# frozen_string_literal: true

module I18n
  module Transformers
    class Collection
      class Generic < Base
        def initialize(name: nil, **options, &block)
          super(**options, &block)
          @name = name ? name.to_s : to_s
          raise ArgumentError, 'block is missing' unless @block
        end

        def transform(key, value)
          @block.call(key, value)
        end
      end
    end
  end
end
