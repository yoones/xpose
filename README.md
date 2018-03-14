# Xpose

[![Gem Version](https://img.shields.io/gem/v/xpose.svg)](https://rubygems.org/gems/xpose)

## Presentation

**Xpose** provides the `expose` and `expose!` helpers to let you write smaller, cleaner controllers.

`expose` provides inference features to guess what you want it to be (lazy loading).\
`expose!` is the eager loading version of `expose`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'xpose'
```

And then execute:

```shell
bundle install
```

## Basic usage

Here is a basic Xpose-friendly controller example:

```ruby
class ArticlesController < ApplicationController
  expose :articles
  expose :article

  def index
  end

  def show
  end

  def new
  end

  def create
    if article.save
      redirect_to article, notice: 'Article was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if article.update(article_params)
      redirect_to article, notice: 'Article was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    article.destroy
    redirect_to articles_url, notice: 'Article was successfully destroyed.'
  end

  private

  def article_params
    params.require(:article).permit(:name)
  end
end
```

## Features

### Inference

When no value is given, `expose` assumes that a model can be infered from the exposed attribute name

#### Collection
When the name is in a **plural form**, it infers that the value should be a **collection** of said model.

```ruby
expose :projects

# Is equivalent to:
expose :projects, -> { Project.all }
```

#### Record
When the name is in a **singular form**, it infers that the value should be a **record** of said model.

Two things to know:
1. The source shall either be a previously exposed collection or a model otherwise.
2. If `params[:id]` exists, it calls `.find(params[:id])`. Otherwise, it calls `.new`

```ruby
# Given params[:id] exists:
expose :project

# Is equivalent to:
expose :project, -> { Project.find(params[:id]) }
```

```ruby
# Given params[:id] exists:
expose :projects, -> { Project.where(visible: true).all }
expose :project

# Is equivalent to:
expose :project, -> { projects.find(params[:id]) }
```

```ruby
# Given params[:id] doesn't exist:
expose :project

# Is equivalent to:
expose :project, -> { Project.new }
```

### Collection options

#### scope

`:scope`: Specify which model scope to use. Default is `:all`.

```ruby
expose :projects, scope: :visible

# Is equivalent to:
expose :projects, -> { Project.visible }
```

#### decorate / decorator

`:decorate`: Choose whether the value should be decorated or not. Default is `true`.
`:decorator`: Specify which decorator to use. Default is `:infer`.

`:decorator` accepts the following values:
- a class: It creates an instance of this class with the attribute as parameter (`WhateverClass.new(attribute)`)
- a symbol: If it matches an existing method, this method is called with the attribute as paramter. Otherwise, this name is translated to a class name and if it matches an existing class, it behaves as if this class was given (see class behavior above).
- a Proc: It calls this proc
- `:infer`: Compatible with [draper](https://www.github.com/draper). It assumes that a ModelDecorator class exists and uses it (see class behavior above).

```ruby
expose :project

# Is equivalent to:
expose :project, -> { ProjectDecorator.new(Project.find(params[:id])) }
```

```ruby
expose :project, decorator: OpenSourceProjectDecorator

# Is equivalent to:
expose :project, -> { OpenSourceProjectDecorator.new(Project.find(params[:id])) }
```

### With no options

In its simplest form, `expose` will assume that a model can be infered from the exposed attribute name.
If the attribute's name is in a plural form, it assumes you want a collection (`expose :projects` -> `@projects = Project.all`). Otherwise, it assumes you want a record.

Collection example:

```ruby
# This:
expose :projects

# is equivalent to:
expose :projects, -> { Project.all }
```

Record example:

```ruby
# This:
expose :project

# is equivalent to:
expose :projects, -> { Project.all }
```







Default values:
`expose :name, :infer, scope: :all, decorate: true, decorator: :infer`

Examples:

```ruby
expose :articles
expose :articles, scope: :visible
expose :article
expose :forthy_two, -> { 42 }, decorate: false
expose :bob, -> { "Bob" }, decorator: -> { |v| v.length }

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yoones/xpose. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Xpose project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/yoones/xpose/blob/master/CODE_OF_CONDUCT.md).
