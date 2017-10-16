[![Build Status](https://travis-ci.org/smakagon/eventify_pro.svg?branch=master)](https://travis-ci.org/smakagon/eventify_pro)

# EventifyPro

Client for [EventifyPro API](http://api.eventify.pro). Allows to publish events from Ruby-applications.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'eventify_pro'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install eventify_pro

## Usage
___
### Getting Started:
This guide assumes you have created an account and obtained an API key from [EventifyPro](http://eventify.pro)

It's really easy to start publishing events with EventifyPro, just 2 lines of code:

```ruby
client = EventifyPro::Client.new(api_key: 'secret')
client.publish(type: 'OrderCreated', data: { order_id: 1, amount: 500 })
```

### Ruby On Rails
In a basic Ruby On Rails application you could create class under `lib` directory:

```ruby
# lib/eventify.rb

class Eventify
  def self.client
    @client ||= EventifyPro::Client.new(api_key: 'secret', logger: Rails.logger)
  end

  def self.publish(event_type, data)
    client.publish(type: event_type, data: data)
  end
end
```
Great, now to publish event from any place of your app use:

```ruby
Eventify.publish('UserSignedUp', user_id: 1, first_name: 'John', last_name: 'Doe')
```

* `type`: type of the event

* `data`: key and value pairs pertaining to the event

Don't forget to enable loading of the `lib` directory in application.rb file:

```ruby
# config/application.rb

config.autoload_paths << Rails.root.join('lib')
```
___
#### Example:
```ruby
class OrdersController < ApplicationController
  def create
    @order = Order.new(params[:order])

    if @order.save
      Eventify.publish(type: 'OrderCreated', data: { order_id: @order.id, amount: @order.amount })
      redirect_to @order, notice: 'Post was successfully created.'
    else
      render :new
    end
  end
end
```
___
## Configuration

#### `raise_errors:`
* By default, `EventifyPro::Client` will swallow errors. It will return `true` or `false` depending on the result of publishing.
* It's possible to pass `raise_errors: true`. In that case client will throw `EventifyPro::Error` exception if something went wrong.

Example:
```ruby
client = EventifyPro::Client.new(api_key: 'secret', raise_errors: true)
begin
  client.publish(type: 'OrderCreated', data: { order_id: 1, amount: 1500 })
rescue EventifyPro::Error
  # exception handling
end
```

#### `logger`
* By default, client will use STDOUT to print error details.
* You can provide any logger that responds to `.info(message)`. For example `Rails.logger`.

Example:
```ruby
client = EventifyPro::Client.new(api_key: 'secret', logger: Rails.logger)
```

### `async` for `publish`
By default publishing will happen in async way in the separate thread.
To publish event in synchronous way, just specify `async: false` option

```ruby
client = EventifyPro::Client.new(api_key: 'secret')
client.publish(type: 'OrderCreated', data: { amount: 500 }, async: false)
```

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Eventify project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/smakagon/eventify/blob/master/CODE_OF_CONDUCT.md).
