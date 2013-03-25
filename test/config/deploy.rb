set :application, "capistrano-upstart"
set :repository, "."
set :deploy_to do
  File.join("/home", user, application)
end
set :deploy_via, :copy
set :scm, :none
set :use_sudo, false
set :user, "vagrant"
set :password, "vagrant"
set :ssh_options, {:user_known_hosts_file => "/dev/null"}

## upstart ##
set(:upstart_service_name, "capistrano-upstart")
set(:upstart_script, <<-EOS)
  echo "hello, world"
EOS

role :web, "192.168.33.10"
role :app, "192.168.33.10"
role :db,  "192.168.33.10", :primary => true

$LOAD_PATH.push(File.expand_path("../../lib", File.dirname(__FILE__)))
require "capistrano-upstart"

def assert_file_exists(file, options={})
  begin
    _invoke_command("test -f #{file.dump}", options)
  rescue
    logger.debug("assert_file_exists(#{file}) failed.")
    _invoke_command("ls #{File.dirname(file).dump}", options)
    raise
  end
end

def assert_file_not_exists(file, options={})
  begin
    _invoke_command("test \! -f #{file.dump}", options)
  rescue
    logger.debug("assert_file_not_exists(#{file}) failed.")
    _invoke_command("ls #{File.dirname(file).dump}", options)
    raise
  end
end

def assert_command(cmdline, options={})
  begin
    _invoke_command(cmdline, options)
  rescue
    logger.debug("assert_command(#{cmdline}) failed.")
    raise
  end
end

def assert_command_fails(cmdline, options={})
  failed = false
  begin
    _invoke_command(cmdline, options)
  rescue
    logger.debug("assert_command_fails(#{cmdline}) failed.")
    failed = true
  ensure
    abort unless failed
  end
end

def reset_upstart!
  variables.each_key do |key|
    reset!(key) if /^upstart_/ =~ key
  end
end

def uninstall_services!
  sudo("service #{upstart_service_name.dump} stop || true")
  sudo("rm -f #{upstart_service_file.dump}")
end

task(:test_all) {
  find_and_execute_task("test_default")
}

on(:start) {
  run("rm -rf #{deploy_to.dump}")
}

namespace(:test_default) {
  task(:default) {
    methods.grep(/^test_/).each do |m|
      send(m)
    end
  }
  before "test_default", "test_default:setup"
  after "test_default", "test_default:teardown"

  task(:setup) {
    uninstall_services!
    find_and_execute_task("deploy:setup")
    find_and_execute_task("deploy")
  }

  task(:teardown) {
    uninstall_services!
  }
}

# vim:set ft=ruby sw=2 ts=2 :
