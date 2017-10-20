require 'spec_helper'

RSpec.describe I18n::Transformers::Collection::Generic do
  describe "initialization" do
    it "should not allow to initialize this class without block" do
      expect{I18n::Transformers::Collection::Generic.new}.to raise_error ArgumentError
    end

    it "should generate name automatically" do
      generic = I18n::Transformers::Collection::Generic.new do; end
      expect(generic.name).to eql generic.to_s
    end

    it "should allow to override name" do
      generic = I18n::Transformers::Collection::Generic.new name: 'my_name' do; end
      expect(generic.name).to eql 'my_name'
    end
  end

  describe "#transform" do
    it "should use passed block to transform value" do
      generic = I18n::Transformers::Collection::Generic.new do |key, value|
        "#{key} #{value}_fjord"
      end
      expect(generic.transform('<3', 'ev')).to eql '<3 ev_fjord'
    end
  end
end
