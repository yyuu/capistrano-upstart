# capistrano-upstart

a capistrano recipe to manage upstart service.

## Installation

Add this line to your application's Gemfile:

    gem 'capistrano-upstart'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-upstart

## Usage

This recipes will try to set up Upstart service after `deploy:setup` tasks.
To enable this recipe for your application,  add following in you `config/deploy.rb`.

    # config/deploy.rb
    require "capistrano-upstart"
    set :upstart_service_name, "hello"
    set :upstart_script, <<-EOS
      exec echo "hello, world"
    EOS

Following options are available to manage your service.

 * `:upstart_service_name` - the name of your Upstart service.
 * `:upstart_exec` - the `exec` script of your Upstart service.
 * `:upstart_script` - the script of your Upstart service. You must specify either `:upstart_exec` or `:upstart_script`.
 * `:upstart_pre_start_script` - the `pre-start` script of your Upstart service.
 * `:upstart_post_start_script` - the `post-start` script of your Upstart service.
 * `:upstart_pre_stop_script` - the `pre-stop` script of your Upstart service.
 * `:upstart_post_stop_script` - the `post-stop` script of your Upstart service.
 * `:upstart_start_on` - specify when your service should be starting on. By default runlevel 2, 3, 4 and 5.
 * `:upstart_stop_on` - specify when your service should be stopping on. By default runlevel 0, 1 and 6.
 * `:upstart_env` - environmental variables for your service.
 * `:upstart_chdir` - specify the working directory of service. Use `:current_path` by default.
 * `:upstart_console` - the `console` directive of Upstart. `none` by default.
 * `:upstart_respawn` - specify whether service should be respawned or not. `true` by default.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Author

- YAMASHITA Yuu (https://github.com/yyuu)
- Geisha Tokyo Entertainment Inc. (http://www.geishatokyo.com/)

## License

MIT
