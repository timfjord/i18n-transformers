module I18n
  module Transformers
    class Collection
      class Base
        def initialize(**options, &block)
          @options = options
          @block = block
        end

        def name
          @name ||= self.class.to_s.demodulize.underscore
        end

        def transform(key, value)
          raise NonImplementedError
        end
      end
    end
  end
end
