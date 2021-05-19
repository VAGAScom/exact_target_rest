[![Gem Version](https://badge.fury.io/rb/exact_target_rest.svg)](https://badge.fury.io/rb/exact_target_rest)

# ExactTargetRest

Simple wrapper around ExactTarget REST API.

It deals with authorization and with coding conventions (CamelCase vs snake_case).

It only supports packages with enhanced functionality (v2), legacy packages are unsupported (v1).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'exact_target_rest'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install exact_target_rest

## Usage

Be sure you have a "Client ID" and a "Client Secret". You can create one in [ExactTarget App Center](https://appcenter-auth.exacttargetapps.com).

Before anything else, create an **Authorization**:

```ruby
auth_url = 'https://acyy6lj5zj3n7gsltjmgv12k0x80.auth.marketingcloudapis.com'
client_id = '123456'
client_secret = '999999999'
auth = ExactTargetRest::Authorization.new(auth_url, client_id, client_secret)
```

### TriggeredSend Activation

There are two ways to use.

The first calls `send_one` and receives DataExtensions as parameters:

```ruby
external_key = 'My TriggeredSend External Key'
ts = ExactTargetRest::TriggeredSend.new(auth, external_key)
ts.send_one(email_address: 'uga@kabuga.com', an_attribute: 'XXX', another_attribute: 'YYY')
```

**email_address** is mandatory, any other field will be put in the DataExtension (or List) associated with the TriggeredSend. You can also pass **subscriber_key** as parameter, if absent, it will use the value in **email_address** as default value.

In first example, with method `send_one`, all other attributes will be converted to CamelCase (ExactTarget convention) before send. So, **an_attribute** and **another_attribute** would become "AnAttribute" and "AnotherAttribute". If you don't want this behavior, pass the flag "snake\_to\_camel: false" in the constructor:

```ruby
ts = ExactTargetRest::TriggeredSend.new(auth, external_key, snake_to_camel: false)
```

The second way helps in two situations:

- If you have DataExtension's keys with spaces or any unusual pattern

```ruby
external_key = 'My TriggeredSend External Key'
ts = ExactTargetRest::TriggeredSend.new(auth, external_key)
ts.with_options(email_address: 'uga@kabuga.com', subscriber_attributes: { 'An Attribute' => 'XXX', 'Another_Attribute' => 'YYY' }).deliver
```

- if you have to call the api asynchronously

```ruby
def deliver
  external_key = 'My TriggeredSend External Key'
  triggered_send = ExactTargetRest::TriggeredSend.new(auth, external_key)
  triggered_send.with_options(email_address: 'uga@kabuga.com')

  Worker.perform_async(triggered_send.to_yaml)
end

class Worker
  include Sidekiq::Worker

  sidekiq_options queue: :exact_target_mailer

  def perform(triggered_send)
    YAML::load(triggered_send).deliver
  end
end

```

### DataExtension Upsert

```ruby
external_key = 'My TriggeredSend External Key'
de = ExactTargetRest::DataExtension.new(auth, external_key, key_field: 'my_key')

# Single upsert
de.upsert(my_key: 123, an_attribute: 'XXX', another_attribute: 'YYY')

# Batch upsert
de.upsert([{my_key: 123, an_attribute: 'XXX', another_attribute: 'YYY'},
           {my_key: 456, an_attribute: 'WWW', another_attribute: 'ZZZ'}])
```

Parameters are CamelCased as in TriggeredSend. This also have a "snake_to_camel" flag in constructor.

If you have a composed primary key, you can use:

```ruby
de = ExactTargetRest::DataExtension.new(auth, external_key, key_fields: ['my_key1', 'my_key2'])
```

Notice the pluralization: "key_field" becomes "key_fields".


## Contributing

Disclaimer 1: It's far from complete, we going to add new services as needed. However, the ones here are being used in production.

Disclaimer 2: We are not representatives of ExactTarget. Please, don't demand features, but we DO accept code contributions. ^\_^

Disclaimer 3: MIT license. Use "as is" (or contribute) :D

1. Fork it ( https://github.com/vagas/exact_target_rest/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
