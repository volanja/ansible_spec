require 'serverspec'
require 'net/ssh'
require 'ansible_spec'
require 'winrm'

#
# Set ansible variables to serverspec property
#
host = ENV['TARGET_HOST']

group_idx = ENV['TARGET_GROUP_INDEX'].to_i
vars = AnsibleSpec.get_variables(host, group_idx)
set_property vars

user = property['ansible_ssh_user'] || property['ansible_user'] || ENV['TARGET_USER']
port = property['ansible_ssh_port'] || property['ansible_port'] || ENV['TARGET_PORT']
keys = property['ansible_ssh_private_key_file'] || property['ansible_private_key_file'] || ENV['TARGET_PRIVATE_KEY']

# !Note: This pass variable will be used only to WinRM connection
pass ||= property['ansible_ssh_pass'] || property['ansible_password'] || ENV['TARGET_PASSWORD']

p "d1:user:#{user} ,ansible_user: #{property['ansible_user']}, ansible_ssh_user: #{property['ansible_ssh_user']}\n"
p "d2:port:#{port} ,ansible_ssh_port: #{property['ansible_ssh_port']}, ansible_port: #{property['ansible_port']}\n"
p "d3:keys:#{keys} ,ansible_ssh_private_key_file: #{property['ansible_ssh_private_key_file']}, ansible_private_key_file: #{property['ansible_private_key_file']}\n"
p "d4:pass:#{pass} ,ansible_ssh_pass: #{property['ansible_ssh_pass']}, ansible_password: #{property['ansible_password']}\n"

if property['ansible_connection'] != 'winrm'
#
# In the case of the unix system. 
#
  set :backend, :ssh
  set :request_pty, true

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

  options = Net::SSH::Config.for(host)

  options[:user] ||= user
  options[:port] ||= port
  options[:keys] ||= keys

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
# In the case of the windows system. 
#
  set :backend, :winrm
  set :os, :family => 'windows'

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
