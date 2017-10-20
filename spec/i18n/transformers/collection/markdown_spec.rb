require 'spec_helper'

RSpec.describe I18n::Transformers::Collection::Markdown do
  let(:markdown) { I18n::Transformers::Collection::Markdown.new }
  let(:kramdown_markdown) { I18n::Transformers::Collection::Markdown.new adapter: 'kramdown' }

  describe "#available_adapters" do
    it "should return list of available markdown adapters" do
      expect(markdown.available_adapters).to eql %w(redcarpet kramdown)
    end
  end

  describe "#adapter" do
    it "should detect adapter based on its availability" do
      expect(markdown.adapter).to eql 'redcarpet'
    end

    it "should calculate adapter only once" do
      markdown.adapter

      expect(markdown).not_to receive(:available_adapters)
    end

    it "should allow to specify adapter" do
      kramdown_markdown = I18n::Transformers::Collection::Markdown.new adapter: 'kramdown'
      expect(kramdown_markdown.adapter).to eql 'kramdown'
    end
  end

  describe "#transform" do
    let(:custom_markdown) do
      I18n::Transformers::Collection::Markdown.new do |key, value|
        "custom markdown for #{key} #{value}"
      end
    end
    let(:string_with_html_safe) do
      str = 'before-html-safe'
      allow(str).to receive(:html_safe).and_return 'after-html-safe'
      str
    end
    let(:custom_markdown_with_html_safe) do
      I18n::Transformers::Collection::Markdown.new do |key, value|
        string_with_html_safe
      end
    end
    let(:markdown_with_custom_pattern) do
      I18n::Transformers::Collection::Markdown.new key_pattern: /_markdown$/
    end

    it "should use passed block if pattern has matched" do
      expect(custom_markdown.transform('key_md', 'v')).to eql 'custom markdown for key_md v'
      expect(custom_markdown.transform('key.md', 'v')).to eql 'custom markdown for key.md v'
    end

    it "should mark string as html_safe if possible if block was passed" do
      expect(custom_markdown_with_html_safe.transform('key_md', string_with_html_safe)).to eql 'after-html-safe'
    end

    it "should convert to markdown using current adapter" do
      expect(markdown.transform('key_md', '**bold**')).to eql "<p><strong>bold</strong></p>\n"
      expect(markdown.transform('key.md', '*italic*')).to eql "<p><em>italic</em></p>\n"
    end

    it "should convert to markdown using specified adapter" do
      expect(kramdown_markdown.transform('key_md', '**bold**')).to eql "<p><strong>bold</strong></p>\n"
    end

    it "should allow to specify different pattern" do
      expect(markdown_with_custom_pattern.transform('key_md', '**bold**')).to eql '**bold**'
      expect(markdown_with_custom_pattern.transform('key_markdown', '**bold**')).to eql "<p><strong>bold</strong></p>\n"
    end
  end
end
