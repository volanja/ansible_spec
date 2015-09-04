require 'serverspec'
require 'net/ssh'
require 'yaml'
require 'json'

if ENV['CONNECTION'] == 'local'
  set :backend, :exec
#  set :pre_command, 'sudo -s'
else
  set :backend, :ssh
  # automatically runs as sudo
end

if ENV['ASK_SUDO_PASSWORD']
  begin
    require 'highline/import'
  rescue LoadError
    fail "highline is not available. Try installing it."
  end
  set :sudo_password, ask("Enter sudo password: ") { |q| q.echo = false }
else
  set :sudo_password, ENV['SUDO_PASSWORD']
end

host = ENV['TARGET_HOST']

options = Net::SSH::Config.for(host)

options[:user] ||= ENV['TARGET_USER']
options[:port] ||= ENV['TARGET_PORT']
options[:keys] ||= ENV['TARGET_PRIVATE_KEY']

set :host,        options[:host_name] || host
set :ssh_options, options

# Disable sudo
# set :disable_sudo, true

# Set environment variables
# set :env, :LANG => 'C', :LC_MESSAGES => 'C'

# Set PATH
# set :path, '/sbin:/usr/local/sbin:$PATH'

# Getting the ansible variables from included vars_files and
# playbook vars to be usable in the tests
vars_files ||= ENV['VARS_FILES']
ansible_vars ||= ENV['VARS'] ? JSON.load(ENV['VARS']) : {}

if vars_files
  vars = {}
  vars_files.split(',').each do |file|
    tmp_vars = YAML.load_file(file)
    tmp_vars.each do |k, v|
      v.gsub!(/{{(.+)}}/, "#{tmp_vars[$1]}")
    end
    vars.merge!(tmp_vars)
  end
  ansible_vars.merge!(vars)
end

ANSIBLE_VARS = ansible_vars
