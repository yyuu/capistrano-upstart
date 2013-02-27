# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano-upstart/version'

Gem::Specification.new do |gem|
  gem.name          = "capistrano-upstart"
  gem.version       = Capistrano::Upstart::VERSION
  gem.authors       = ["Yamashita Yuu"]
  gem.email         = ["yamashita@geishatokyo.com"]
  gem.description   = %q{a capistrano recipe to manage upstart serivce.}
  gem.summary       = %q{a capistrano recipe to manage upstart serivce.}
  gem.homepage      = "https://github.com/yyuu/capistrano-upstart"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency("capistrano")
  gem.add_dependency("capistrano-file-resources", "~> 0.0.1")
  gem.add_dependency("capistrano-file-transfer-ext", "~> 0.0.3")
end
