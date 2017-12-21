# 🛶⚡️ Argonaut CLI

Use Argonaut from your command line!

## Installation

```ruby
gem install argonaut-cli
```

Create the config file `~/.argonaut.yml` and populate it with the sample config below:

```yaml
# The only required fields needed by the gem to function are api_token and url_root

api_token: YOUR_TOKEN
url_root: https://theargonaut-api.herokuapp.com

# Below are the optional settings to customize output

options:
  colorize_rows: true
  time_format: '%d %b %Y %l:%M %p'
  high_contrast_colors: true
```

Replace `YOUR_TOKEN` in the sample config above with your own token that can be found in the Profile page in the web app.

You can also export environment variables `ARGONAUT_API_TOKEN` and `ARGONAUT_URL_ROOT` with the correct values without needing a config file.

## Usage

By default, invoking `argonaut` lists all your environment reservations.

**View all registered teams:**

```
argonaut -T
```

**View reservations table on a particular team's environments:**

Using team id
```
argonaut -t 1
```

Using team name
```
argonaut -t EPA
```

**Make a reservation:**

```
argonaut -r pbm1:epamotron
```

**Release when you are done testing in that environment:**

```
argonaut -R pbm1:epamotron
```
**Clear all your reservations at once**

```
argonaut -c
```

Full list of options can be viewed by running `argonaut -h`. If you are using zsh, you can generate shell completion and add it to your `~/.zshrc` like so:

```
echo compdef _gnu_generic argonaut >> ~/.zshrc
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/qubbit/argonaut-cli/issues. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

