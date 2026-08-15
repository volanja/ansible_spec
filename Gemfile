source 'https://rubygems.org'

# Specify your gem's dependencies in ansible_spec.gemspec
gemspec

if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.1')
  # Ansible::Vault support Ruby 2.1.0 and higher.
  gem 'ansible-vault'
end
