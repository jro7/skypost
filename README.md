# Skypost

A Ruby gem for posting messages to Bluesky social network.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'skypost'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install skypost

## Usage

```ruby
require 'skypost'

# Initialize the client with your Bluesky credentials
# You can use either your custom domain or .bsky.social handle
client = Skypost::Client.new("username.com", "your-app-password")
# OR
client = Skypost::Client.new("username.bsky.social", "your-app-password")

# Post a message
client.post("Hello from Skypost!")

# Post a message with a clickable link
client.post('Check out this cool website: <a href="https://example.com">Example</a>!')
```

### App Password
To get your app password, go to your Bluesky account settings at [bsky.app/settings/app-passwords](https://bsky.app/settings/app-passwords) and create a new app password. Never use your main account password for API access.

### Handle Format
You can use either:
1. Your custom domain (if you have one), e.g., `username.com`
2. Your Bluesky handle in the format `username.bsky.social`

To find your handle, look at your profile URL in Bluesky. For example:
- If your profile is at `https://bsky.app/profile/username.com`, use `username.com`
- If your profile is at `https://bsky.app/profile/username.bsky.social`, use `username.bsky.social`

## Development

After checking out the repo, run `bundle install` to install dependencies.

## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

The gem is available as open source under the terms of the MIT License.
