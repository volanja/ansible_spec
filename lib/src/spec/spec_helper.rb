require 'serverspec'
require 'net/ssh'
require 'ansible_spec'
require 'winrm'

#
# Set ansible variables to serverspec property
#
host = ENV['TARGET_HOST']
hosts = ENV["TARGET_HOSTS"]

group_idx = ENV['TARGET_GROUP_INDEX'].to_i
vars = AnsibleSpec.get_variables(host, group_idx,hosts)
set_property vars

connection = ENV['TARGET_CONNECTION']

if connection != 'winrm'
#
# OS type: UN*X
#
  set :backend, :ssh

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

  unless ENV['SSH_CONFIG_FILE']
    options = Net::SSH::Config.for(host)
  else
    options = Net::SSH::Config.for(host, files=[ENV['SSH_CONFIG_FILE']])
  end

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
else
#
# OS type: Windows
#
  set :backend, :winrm
  set :os, :family => 'windows'

  user = ENV['TARGET_USER']
  port = ENV['TARGET_PORT']
  pass = ENV['TARGET_PASSWORD']

  if user.nil?
    begin
      require 'highline/import'
    rescue LoadError
      fail "highline is not available. Try installing it."
    end
    user = ask("\nEnter #{host}'s login user: ") { |q| q.echo = true }
  end
  if pass.nil?
    begin
      require 'highline/import'
    rescue LoadError
      fail "highline is not available. Try installing it."
    end
    pass = ask("\nEnter #{user}@#{host}'s login password: ") { |q| q.echo = false }
  end

  endpoint = "http://#{host}:#{port}/wsman"

  winrm = ::WinRM::WinRMWebService.new(endpoint, :ssl, :user => user, :pass => pass, :basic_auth_only => true)
  winrm.set_timeout 300 # 5 minutes max timeout for any operation
  Specinfra.configuration.winrm = winrm

end
