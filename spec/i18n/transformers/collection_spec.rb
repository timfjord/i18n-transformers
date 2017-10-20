require 'spec_helper'

RSpec.describe I18n::Transformers::Collection do
  let(:collection) { I18n::Transformers::Collection.new }
  let(:transformer1) { I18n::Transformers::Collection::Generic.new name: 'transformer1' do; end }
  let(:transformer2) { I18n::Transformers::Collection::Markdown.new }
  let(:transformer3) { I18n::Transformers::Collection::Generic.new do; end }

  describe "#insert" do
    it "should add transformer to collection" do
      collection.insert transformer1
      expect(collection.all).to eql [transformer1]
    end

    it "should allow to insert before some transformer" do
      collection.insert transformer1
      collection.insert transformer2, before: 'transformer1'
      expect(collection.all).to eql [transformer2, transformer1]
    end

    it "should allow to insert after some transformer" do
      collection.insert transformer1
      collection.insert transformer2
      collection.insert transformer3, after: transformer1
      expect(collection.all).to eql [transformer1, transformer3, transformer2]
    end

    it "should allow to insert at specific position" do
      collection.insert transformer1
      collection.insert transformer2, at: 0
      expect(collection.all).to eql [transformer2, transformer1]
    end

    it "should allow not allow to insert at negative index or index that is bigger than size" do
      collection.insert transformer1
      expect{collection.insert transformer2, at: -1}.to raise_error ArgumentError
      expect{collection.insert transformer2, at: 2}.to raise_error ArgumentError
    end

    it "should allow only one option" do
      expect{collection.insert transformer1, at: 0, before: 'smth'}.to raise_error ArgumentError
      expect{collection.insert transformer1, at: 0, after: 'smth'}.to raise_error ArgumentError
      expect{collection.insert transformer1, before: 'smth', after: 'smth'}.to raise_error ArgumentError
      expect{collection.insert transformer1, at: 0, before: 'smth', after: 'smth'}.to raise_error ArgumentError
    end
  end

  describe "#register" do
    it "should allow to register transformer by name" do
      collection.register :markdown

      expect(collection.all.size).to eql 1
      expect(collection.all.first).to be_kind_of I18n::Transformers::Collection::Markdown
      expect(collection.all.first.name).to eql 'markdown'
    end

    it "should allow to pass transformer instance and register it" do
      collection.register transformer1
      expect(collection.all).to eql [transformer1]
    end

    it "should register generic transformer if name wasn't passed" do
      transformer = collection.register do |key, value|
        'smth'
      end
      expect(collection.all).to eql [transformer]
    end

    it "should allow to pass some attributes to generic transformers" do
      collection.register transformer1
      transformer = collection.register before: 'transformer1' do |key, value|
        'smth'
      end
      expect(collection.all).to eql [transformer, transformer1]
    end

    it "should consider first argument as a name for generic if it was a String" do
      collection.register 'my_name' do |key, value|
        'smth'
      end
      expect(collection.all.first).to be_kind_of I18n::Transformers::Collection::Generic
      expect(collection.all.first.name).to eql 'my_name'
    end

    it "should not try to generete other class than Generic if name is not a Symbol" do
      collection.register 'markdown' do |key, value|
        'smth'
      end
      expect(collection.all.first).to be_kind_of I18n::Transformers::Collection::Generic
      expect(collection.all.first.name).to eql 'markdown'
    end
  end

  describe "#find" do
    it "should find element" do
      collection.register transformer1
      expect(collection.find('transformer1')).to eql transformer1
      expect(collection.find(transformer1)).to eql transformer1
    end

    it "should find element index if such option was passed" do
      collection.register transformer2
      collection.register transformer1
      expect(collection.find('transformer1', index: true)).to eql 1
      expect(collection.find(transformer1, index: true)).to eql 1
    end
  end
end
