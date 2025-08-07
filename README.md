# JSONAPI.rb :electric_plug:

[![Build Status](https://travis-ci.org/stas/jsonapi.rb.svg?branch=master)](https://travis-ci.org/stas/jsonapi.rb)

A modern Ruby gem for building [JSON:API](https://jsonapi.org/) compliant APIs with Rails 8+ and Ruby 3.3+.

> Building JSON:API shouldn't be rocket science. This gem provides simple, powerful tools to get you up and running quickly.

## Features

JSONAPI.rb offers a collection of lightweight modules that integrate seamlessly with your Rails controllers:

* **Object serialization** - Powered by Active Model Serializers
* **Error handling** - JSON:API compliant [error responses](https://jsonapi.org/format/#errors) for parameters, validation, and generic errors
* **Fetching** - Support for [includes](https://jsonapi.org/format/#fetching-includes) and [sparse fields](https://jsonapi.org/format/#fetching-sparse-fieldsets)
* **Filtering & Sorting** - Advanced [filtering](https://jsonapi.org/format/#fetching-filtering) and [sorting](https://jsonapi.org/format/#fetching-sorting) powered by Ransack
* **Pagination** - Built-in [pagination](https://jsonapi.org/format/#fetching-pagination) support with links and metadata

## Installation

**Requirements:**
- Ruby 3.3.0 or higher
- Rails 8.0 or higher

Add this line to your application's Gemfile:

```ruby
gem "jsonapi.rb"
```

And then execute:

    $ bundle install

## Quick Start

### 1. Enable Rails Integration

Add this to an initializer:

```ruby
# config/initializers/jsonapi.rb
require "jsonapi"

JSONAPI::RailsApp.install!
```

This registers the JSON:API media type and renderers.

### 2. Basic Usage

```ruby
class UsersController < ApplicationController
  include JSONAPI::Filtering
  include JSONAPI::Pagination

  def index
    allowed_fields = [ :first_name, :last_name, :created_at ]
    
    jsonapi_filter(User.all, allowed_fields) do |filtered|
      jsonapi_paginate(filtered.result) do |paginated|
        render jsonapi_paginate: paginated
      end
    end
  end

  def show
    user = User.find(params[:id])
    render jsonapi: user
  end
end
```

### 3. Create Serializers

```ruby
class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :created_at, :updated_at
  
  has_many :posts
end
```

## Core Modules

### JSONAPI::Filtering

Provides powerful filtering and sorting using Ransack:

```ruby
class UsersController < ApplicationController
  include JSONAPI::Filtering

  def index
    allowed_fields = [ :first_name, :last_name, :email, :posts_title ]
    
    jsonapi_filter(User.all, allowed_fields) do |filtered|
      render jsonapi: filtered.result
    end
  end
end
```

**Example requests:**
```bash
# Filter by first name containing "John"
GET /users?filter[first_name_cont]=John

# Sort by last name descending, then first name ascending  
GET /users?sort=-last_name,first_name

# Complex filtering with relationships
GET /users?filter[posts_title_matches_any]=Ruby,Rails&sort=-created_at
```

#### Sorting with Expressions

Enable aggregation expressions for advanced sorting:

```ruby
def index
  allowed_fields = [ :first_name, :posts_count ]
  options = { sort_with_expressions: true }
  
  jsonapi_filter(User.joins(:posts), allowed_fields, options) do |filtered|
    render jsonapi: filtered.result.group("users.id")
  end
end
```

```bash
# Sort by post count
GET /users?sort=-posts_count_sum
```

### JSONAPI::Pagination

Handles pagination with JSON:API compliant links:

```ruby
class UsersController < ApplicationController
  include JSONAPI::Pagination

  def index
    jsonapi_paginate(User.all) do |paginated|
      render jsonapi_paginate: paginated
    end
  end

  private

  def jsonapi_meta(resources)
    {
      pagination: jsonapi_pagination_meta(resources),
      total: resources.respond_to?(:count) ? resources.count : resources.size
    }
  end
end
```

**Example requests:**
```bash
# Get page 2 with 20 items per page
GET /users?page[number]=2&page[size]=20
```

### JSONAPI::Fetching

Supports sparse fieldsets and relationship inclusion:

```ruby
class UsersController < ApplicationController
  include JSONAPI::Fetching

  def index
    render jsonapi: User.all
  end

  private

  def jsonapi_include
    # Whitelist allowed includes
    super & [ "posts", "profile" ]
  end
end
```

**Example requests:**
```bash
# Include posts and only return specific fields
GET /users?include=posts&fields[users]=first_name,last_name&fields[posts]=title
```

### Error Handling

```ruby
class UsersController < ApplicationController
  include JSONAPI::Errors

  def create
    user = User.new(user_params)
    
    if user.save
      render jsonapi: user, status: :created
    else
      render jsonapi_errors: user.errors, status: :unprocessable_entity
    end
  end

  def update
    user = User.find(params[:id])
    
    if user.update(user_params)
      render jsonapi: user
    else
      render jsonapi_errors: user.errors, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:data).require(:attributes).permit(:first_name, :last_name, :email)
  end

  def render_jsonapi_internal_server_error(exception)
    # Custom exception handling (e.g., error tracking)
    # Sentry.capture_exception(exception)
    super(exception)
  end
end
```

## Advanced Configuration

### Custom Serializer Resolution

```ruby
class UsersController < ApplicationController
  def index
    render jsonapi: User.all, serializer_class: CustomUserSerializer
  end

  private

  def jsonapi_serializer_class(resource, is_collection)
    JSONAPI::RailsApp.serializer_class(resource, is_collection)
  rescue NameError
    # Fallback serializer logic
    "#{resource.class.name}Serializer".constantize
  end
end
```

### Custom Page Size

```ruby
def jsonapi_page_size(pagination_params)
  per_page = pagination_params[:size].to_i
  return 30 if per_page < 1 || per_page > 100
  per_page
end
```

### Serializer Parameters

```ruby
def jsonapi_serializer_params
  {
    current_user: current_user,
    include_private: params[:include_private].present?
  }
end
```

## Configuration

### Environment Variables

- `PAGINATION_LIMIT` - Default page size (default: 30)

### Dependencies

This gem leverages these excellent libraries:
- [Active Model Serializers](https://github.com/rails-api/active_model_serializers) - Object serialization
- [Ransack](https://github.com/activerecord-hackery/ransack) - Advanced filtering and sorting

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/stas/jsonapi.rb

This project follows the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Development

After checking out the repo:

```bash
bundle install
bundle exec rspec  # Run tests
bundle exec rubocop  # Check code style
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
