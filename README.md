# Faraday OAUTH2 Client Credentials Grant Middleware

Authorizes the request with the [OAUTH2 Client Credentials Grant](https://tools.ietf.org/html/rfc6749#section-4.4) and injects the received token into the Authorization header.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'faraday_oauth2_ccg_middleware'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install faraday_oauth2_ccg_middleware

## Usage

```ruby
Faraday.new do |conn|
    conn.request :oauth2_ccg,
             oauth_host:    'https://server.example.com',
             token_url:     '/token',
             client_id:     's6BhdRkqt3',
             client_secret: '7Fjfp0ZBr1KtDRbnfVdmIw',
             cache_store:   ::ActiveSupport::Cache.lookup_store(:redis_store, 'redis://127.0.0.1:6379')
    
    conn.adapter(:net_http) # NB: Last middleware must be the adapter
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fulf/faraday_oauth2_ccg_middleware. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the FaradayUpOauth2Middleware project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/faraday_oauth2_ccg_middleware/blob/master/CODE_OF_CONDUCT.md).
