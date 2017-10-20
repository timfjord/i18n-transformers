require 'spec_helper'

RSpec.describe I18n::Transformers do
  it "has a version number" do
    expect(I18n::Transformers::VERSION).not_to be nil
  end

  describe "integration" do
    around :each do |example|
      enforce_available_locales = I18n.enforce_available_locales
      I18n.enforce_available_locales = false
      I18n.backend = I18n::Backend::Simple.new
      I18n.backend.store_translations :en, key: 'val', key_md: '**Bold**'
      I18n.reset_transformers

      example.call

      I18n.backend = nil
      I18n.enforce_available_locales = enforce_available_locales
    end

    it "should allow to register transformers globally" do
      md_trasformer = I18n.transformers.register :markdown
      expect(I18n.transformers.all).to eql [md_trasformer]
    end

    it "should process though all available transformers during translte call" do
      I18n.transformers.register do |key, value|
        "#{value}-transformed1"
      end
      I18n.transformers.register do |key, value|
        "#{value}-transformed2"
      end
      I18n.with_locale :en do
        expect(I18n.translate(:key)).to eql 'val-transformed1-transformed2'
      end
    end

    it "should work with predefined transformers" do
      I18n.transformers.register :markdown
      I18n.with_locale :en do
        expect(I18n.translate(:key)).to eql 'val'
        expect(I18n.translate(:key_md)).to eql "<p><strong>Bold</strong></p>\n"
      end
    end

    it "should not apply transformation for missing translation", skip: 'Missing translations' do
      I18n.transformers.register do |key, value|
        "#{value}-transformed"
      end
      I18n.with_locale :en do
        expect(I18n.translate(:missing_key)).to eql 'translation missing: en.missing_key'
      end
    end
  end
end
