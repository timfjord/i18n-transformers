require 'spec_helper'

RSpec.describe I18n::Transformers::Collection::Base do
  describe "#name" do
    it "should calculate name from class name" do
      expect(I18n::Transformers::Collection::Base.new.name).to eql 'base'
    end
  end
end
