# I18n::Transformers

[![Build Status](https://travis-ci.org/timsly/i18n-transformers.svg?branch=master)](https://travis-ci.org/timsly/i18n-transformers)

Transformers for `I18n` ruby library

`I18n::Transformers` is a `I18n` ruby library plugin that allows transform translations.

`I18n::Transformers` can be used if some or even all translations keys require some transformation.
For example parsing markdown or replacing some symbol.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'i18n-transformers'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install i18n-transformers

## Usage

The core of this library is `I18n.transformers.register` method.
It can be used to register various transformers or reset all available transformers.
It is designed to register transformers globally.
It returns transformer instance that can be later used with `before`/`after` options.

If some transformers have to be applied only for some set of keys
then this logic has to implemented in the transformer class itself.
Also, it is very important to return original value in this case(see [Transformers chain section](#transformers-chain))

The gem comes with a few built-in transformers:

* generic transformer
* markdown transformer

If symbol was passed as the first argument to `.register` call
it will search thought built-in transformers and try to register it.
If there is no match generic adapter will be used.

### Generic transformer

Generic transformer is designed to handle custom transformers defined as a block.
It is useful for simple transformations.

To register generic transformer call:

```ruby
I18n.transformers.register do |key, value|
  "transformered-#{value}"
end
```

`I18n.translate` key and translation value will be passed to the block.

Each transformer has its name that helps to register transformer after or before some specific transformer.
By default generic transformer generates unique name for each transformer,
but it can be also explicitly specified by passing name as the first argument.

```ruby
I18n.transformers.register 'my_transformer' do |key, value|
  "transformered-#{value}"
end
```

All transformers can be registered before, after or at specific position.
`before`, `after` and `at` options are used for that.

```ruby
I18n.transformers.register 'my_transformer' do |key, value|
  "transformered1-#{value}"
end

another_transformer = I18n.transformers.register after: 'my_transformer' do |key, value|
  "transformered2-#{value}"
end

I18n.transformers.register before: another_transformer, do |key, value|
  "transformered3-#{value}"
end

I18n.transformers.register at: 1, do |key, value|
  "transformered4-#{value}"
end
```

### Markdown transformer

To register built-in markdown transformer use:

```ruby
I18n.transformers.register :markdown
```

Currently it supports [`redcarpet`](https://github.com/vmg/redcarpet) and [`kramdown`](https://github.com/gettalong/kramdown) markdown parsers.

It uses first available adapter so if both are available `redcarpet` will be picked.
To specify adapter use:

```ruby
I18n.transformers.register :markdown, adapter: :redcarpet
```

Markdown transformer is designed to be triggered only for some set of keys.
By default it triggers only for keys ended with `_md` and `.md`.

So specify custom key pattern use:

```ruby
I18n.transformers.register :markdown, key_pattern: /_markdown$/
```

In the example above markdown transformer will be triggered only if key ended with `_markdown`.

If block was specified it will be used instead.
It can be useful to override default transformation behavior.

```ruby
I18n.transformers.register :markdown do |key, value|
  MyMarkdownParser.parse(value)
end
```

Please note that it will be still running only if key matches `key_pattern` option.

Markdown transformer always uses the same name - `'markdown'` - so to register some transformer after/before it use

```ruby
I18n.transformers.register :markdown

I18n.transformers.register 'my_custom_transformer', after: 'markdown' do |key, value|
  Smth.transform(key, value)
end
```

It is designed to be registered only once that's why `name` is always `markdown`.

### Custom transformers

To register custom transformer use:

```ruby
I18n.transformers.register MyCustomTransformer
```

`MyCustomTransformer` has to be inherited from `I18n::Transformers::Collection::Base` class.
Also, to not break transformers chain(see [Transformers chain section](#transformers-chain)),
it is responsible for returning correct value if it needs to be applied only for some set of keys

All options except `before`, `after` and `at` will be passed as the first argument to `.new` call.

Transformer instance can be passed too:

```ruby
I18n.transformers.register MyCustomTransformer.new(:val1, :val2)
```

### Transformers chain

It is very important to return some value from either block or `#transform` method from the custom transformer class
otherwise transformers chain will be broken.

Here is the bad example of custom transformer:

```ruby
I18n.transformers.register do |key, value|
  if key.to_s.start_with? 'key_prefix'
    value.gsub('^symbol^', 'REPLACED_SYMBOL')
  end
end
```

The code above most likely will be broken for all keys that don't start with `key_prefix`.
To fix that we should always fallback to the original value

```ruby
I18n.transformers.register do |key, value|
  if key.to_s.start_with? 'key_prefix'
    value.gsub('^symbol^', 'REPLACED_SYMBOL')
  else
    value
  end
end
```

### Reseting transformers

This library is designed to register all transformers globally.
In a rails app it can be done in initializer.
But if there is a need to reset all transformers `.reset` method can be used.

```ruby
I18n.transformers.reset
```

## Example

To illustrate how this gem works let's assume the following setup

```yaml
en:
  key: my key1 value ^symbol^
  key_md: '**Text with ^symbol^**'
  key_markdown: '*^symbol^*'
```

```ruby
I18n.transformers.register :markdown # let's assume redcarpet gem is available

I18n.transformers.register do |key, value|
  value.gsub('^symbol^', 'REPLACED_SYMBOL')
end
```

Then
```ruby
I18n.translate :key # => my key1 value REPLACED_SYMBOL

I18n.translate :key_md # => <p><strong>Text with REPLACED_SYMBOL</strong></p>

I18n.translate :key_markdown # => *REPLACED_SYMBOL*
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## TODO

* Think more about missing translations and find a nice way to handle them

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/timsly/i18n-transformers.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
