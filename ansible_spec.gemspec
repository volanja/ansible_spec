# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ansible_spec/version'

Gem::Specification.new do |gem|
  gem.name          = "ansible_spec"
  gem.version       = AnsibleSpec::VERSION
  gem.authors       = ["volanja"]
  gem.email         = ["volaaanja@gmail.com"]
  gem.description   = %q{This is Severspec template for Run test Multi Role and Multi Host with Ansible}
  gem.summary       = %q{This is Severspec template for Run test Multi Role and Multi Host with Ansbile}
  gem.homepage      = "https://github.com/volanja"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "bundler", "~> 1.3"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "serverspec", ">= 0.13.5"

  gem.add_runtime_dependency "serverspec", ">= 0.13.5"

end
