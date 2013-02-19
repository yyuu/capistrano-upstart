require "capistrano-upstart/version"
require 'erb'

module Capistrano
  module Upstart
    def self.extended(configuration)
      configuration.load {
        namespace(:deploy) {
          desc("Start upstart service.")
          task(:start, :roles => :app, :except => { :no_release => true }) {
            find_and_execute_task("upstart:start")
          }

          desc("Stop upstart service.")
          task(:stop, :roles => :app, :except => { :no_release => true }) {
            find_and_execute_task("upstart:stop")
          }

          desc("Restart upstart service.")
          task(:restart, :roles => :app, :except => { :no_release => true }) {
            find_and_execute_task("upstart:restart")
          }
        }

        namespace(:upstart) {
          _cset(:upstart_template_source_path, File.join(File.dirname(__FILE__), 'templates'))
          _cset(:upstart_template_files) {
            [
              "#{upstart_service_name}.conf",
              "#{upstart_service_name}.conf.erb",
              "upstart.conf",
              "upstart.conf.erb",
            ]
          }

          _cset(:upstart_service_file) {
            "/etc/init/#{upstart_service_name}.conf"
          }
          _cset(:upstart_service_name) {
            abort("You must set upstart_service_name explicitly.")
          }

          _cset(:upstart_start_on, { :runlevel => "[2345]" })
          _cset(:upstart_stop_on, { :runlevel => "[016]" })
          _cset(:upstart_env, {})
          _cset(:upstart_export) {
            upstart_env.keys
          }
          _cset(:upstart_script) {
            abort("You must specify either :upstart_exec or :upstart_script.")
          }

          _cset(:upstart_chdir) { current_path }
          _cset(:upstart_console, 'none')
          _cset(:upstart_respawn, true)
          _cset(:upstart_options) {{
            "author" => fetch(:upstart_author, 'unknown').to_s.dump,
            "chdir" => upstart_chdir,
            "console" => upstart_console,
            "description" => fetch(:upstart_description, application).to_s.dump,
            "respawn" => upstart_respawn,
          }}

          desc("Setup upstart service.")
          task(:setup, :roles => :app, :except => { :no_release => true }) {
            transaction {
              configure
            }
          }
          after 'deploy:setup', 'upstart:setup'

          task(:configure, :roles => :app, :except => { :no_release => true }) {
            tempfile = capture("t=$(mktemp /tmp/capistrano-upstart.XXXXXXXXXX;rm -f $t;echo $t").chomp
            begin
              template = upstart_template_files.map { |f| File.join(upstart_template_source_path, f) }.find { |t| File.file?(t) }
              unless template
                abort("could not find template for upstart configuration file for `#{upstart_service_name}'.")
              end
              case File.extname(template)
              when '.erb'
                put(ERB.new(File.read(template)).result(binding), tempfile)
              else
                put(File.read(template), tempfile)
              end
              run("diff -u #{upstart_service_file} #{tempfile} || #{sudo} mv -f #{tempfile} #{upstart_service_file}")
            ensure
              run("rm -f #{tempfile}")
            end
          }

          desc("Start upstart service.")
          task(:start, :roles => :app, :except => { :no_release => true }) {
            run("#{sudo} service #{upstart_service_name} start")
          }

          desc("Stop upstart service.")
          task(:stop, :roles => :app, :except => { :no_release => true }) {
            run("#{sudo} service #{upstart_service_name} stop")
          }

          desc("Restart upstart service.")
          task(:restart, :roles => :app, :except => { :no_release => true }) {
            run("#{sudo} service #{upstart_service_name} restart || #{sudo} service #{upstart_service_name} start")
          }

          desc("Reload upstart service.")
          task(:reload, :roles => :app, :except => { :no_release => true }) {
            run("#{sudo} service #{upstart_service_name} reload || #{sudo} service #{upstart_service_name} start")
          }

          desc("Show upstart service status.")
          task(:status, :roles => :app, :except => { :no_release => true }) {
            run("#{sudo} service #{upstart_service_name} status")
          }
        }
      }
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Configuration.instance.extend(Capistrano::Upstart)
end

# vim:set ft=ruby :
