require 'i18n'
require 'active_support/inflector'

require 'i18n/transformers/version'

require 'i18n/transformers/collection'
require 'i18n/transformers/collection/base'
require 'i18n/transformers/collection/generic'
require 'i18n/transformers/collection/markdown'

module I18n
  module Transformers
    def reset_transformers
      @transformers = Collection.new
    end

    def transformers
      @transformers ||= Collection.new
    end

    def translate(*args)
      result = super

      # TODO: Handle missing translations.
      # In theory we don't need to pass them to transformers, but there is no nice way to do that,
      # only with force raising and handling it again

      key = args.first
      transformers.all.inject(result) do |transformed, transformer|
        transformer.transform(key, transformed)
      end
    end
  end

  extend Transformers
end
