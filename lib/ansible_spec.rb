require "ansible_spec/version"
require "fileutils"

# Reference
# https://github.com/serverspec/serverspec/blob/master/lib/serverspec/setup.rb
# Reference License (MIT)
# https://github.com/serverspec/serverspec/blob/master/LICENSE.txt

module AnsibleSpec

  def self.main()
    safe_create_spec_helper
    safe_create_rakefile
  end


  def self.safe_create_spec_helper
    content = <<'EOF'
require 'serverspec'
require 'pathname'
require 'net/ssh'

include SpecInfra::Helper::Ssh
include SpecInfra::Helper::DetectOS

RSpec.configure do |c|
  if ENV['ASK_SUDO_PASSWORD']
    require 'highline/import'
    c.sudo_password = ask("Enter sudo password: ") { |q| q.echo = false }
  else
    c.sudo_password = ENV['SUDO_PASSWORD']
  end
  c.before :all do
    block = self.class.metadata[:example_group_block]
    if RUBY_VERSION.start_with?('1.8')
      file = block.to_s.match(/.*@(.*):[0-9]+>/)[1]
    else
      file = block.source_location.first
    end
    host  = ENV['TARGET_HOST']
    if c.host != host
      c.ssh.close if c.ssh
      c.host  = host
      options = Net::SSH::Config.for(c.host)
      user    = ENV['TARGET_USER']
      options[:keys] = ENV['TARGET_PRIVATE_KEY']
      c.ssh   = Net::SSH.start(host, user, options)
    end
  end
end

EOF
    safe_mkdir("spec")
    safe_touch("spec/spec_helper.rb")
    File.open("spec/spec_helper.rb", 'w') do |f|
      f.puts content
    end

  end

  def self.safe_create_rakefile
    content = <<'EOF'
require 'rake'
require 'rspec/core/rake_task'
require 'yaml'

# param: inventory file of Ansible
# return: Hash {"active_group_name" => ["192.168.0.1","192.168.0.2"]}
def load_host(file)
  if File.exist?(file) == false
    puts 'Error: Please create inventory file. name MUST "hosts"'
    exit
  end
  hosts = File.open(file).read
  active_group = Hash.new
  active_group_name = ''
  hosts.each_line{|line|
    line = line.chomp
    next if line.start_with?('#')
    if line.start_with?('[') && line.end_with?(']')
      active_group_name = line.gsub('[','').gsub(']','')
      active_group["#{active_group_name}"] = Array.new
    elsif active_group_name.empty? == false
      next if line.empty? == true
      active_group["#{active_group_name}"] << line
    end
  }
  return active_group
end

load_file = YAML.load_file('site.yml')

# e.g. comment-out
if load_file === false
  puts 'Error: No data in site.yml'
  exit
end

properties = Array.new
load_file.each do |site|
  if site.has_key?("include")
    properties.push YAML.load_file(site["include"])[0]
  else
    properties.push site
  end
end


#load inventry file
hosts = load_host('hosts')
properties.each do |var|
  if hosts.has_key?("#{var["hosts"]}")
    var["hosts"] = hosts["#{var["hosts"]}"]
  end
end

namespace :serverspec do
  properties.each do |var|
    var["hosts"].each do |host|
      desc "Run serverspec for #{var["name"]}"
      RSpec::Core::RakeTask.new(var["name"].to_sym) do |t|
        puts "Run serverspec for #{var["name"]} to #{host}"
        ENV['TARGET_HOST'] = host
        ENV['TARGET_PRIVATE_KEY'] = '~/.ssh/id_rsa'
        ENV['TARGET_USER'] = var["user"]
        t.pattern = 'roles/{' + var["roles"].join(',') + '}/spec/*_spec.rb'
      end
    end
  end
end

EOF
    safe_touch("Rakefile")
    File.open("Rakefile", 'w') do |f|
      f.puts content
    end
    
  end

  def self.safe_mkdir(dir)
    unless FileTest.exist?("#{dir}")
      FileUtils.mkdir_p("#{dir}")
      TermColor.green
      puts "\t\tcreate\t#{dir}"
      TermColor.reset
    else
      TermColor.red
      puts "\t\texists\t#{dir}"
      TermColor.reset
    end
  end

  def self.safe_touch(file)
    unless File.exists? "#{file}"
      File.open("#{file}", 'w') do |f|
          #f.puts content
      end
      TermColor.green
      puts "\t\tcreate\t#{file}"
      TermColor.reset
    else 
      TermColor.red
      puts "\t\texists\t#{file}"
      TermColor.reset
    end
  end

  class TermColor
    class << self
      # 色を解除
      def reset   ; c 0 ; end 

      # 各色
      def red     ; c 31; end 
      def green   ; c 32; end 

      # カラーシーケンスの出力
      def c(num)
        print "\e[#{num.to_s}m"
      end 
    end 
  end

end
