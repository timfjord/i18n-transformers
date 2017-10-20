module I18n
  module Transformers
    class Collection
      def initialize
        @collection = []
      end

      def all
        @collection
      end

      def find(name_or_obj, index: false)
        name = name_or_obj.respond_to?(:name) ? name_or_obj.name : name_or_obj.to_s
        method = index ? :index : :find

        all.send(method) { |item| item.name == name }
      end

      def register(name = nil, options = {}, &block)
        name, options = nil, name if name.is_a?(Hash)
        position = options.extract! :before, :after, :at

        transformer = if name.respond_to?(:transform)
          name
        else
          klass = name.is_a?(Symbol) ? collection_class_for(name) : name
          klass = I18n::Transformers::Collection::Generic if !klass || name.is_a?(String)
          klass.new(options.merge(name: name), &block)
        end

        insert(transformer, position)
      end

      def insert(transformer, at: nil, before: nil, after: nil)
        unless transformer.respond_to?(:transform)
          raise ArgumentError, 'passed object need to response to transform method'
        end

        if [at, before, after].count(&:nil?) < 2
          raise ArgumentError, 'before, after and at cannot be used at the same time'
        end

        index = at || find(before || after, index: true)

        if index
          raise ArgumentError, 'invalid index' if index < 0 || index > all.size
          @collection.insert(after ? index + 1 : index, transformer)
        else
          @collection << transformer
        end

        transformer
      end

      def reset
        @collection = []
        self
      end

      private

      def collection_class_for(shortcut)
        klass = shortcut.to_s.classify
        "I18n::Transformers::Collection::#{klass}".constantize
      rescue NameError
        nil
      end
    end
  end
end
