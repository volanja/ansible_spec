require 'rake'
require 'rspec/core/rake_task'
require 'yaml'
require 'ansible_spec'

properties = AnsibleSpec.get_properties
# {"name"=>"Ansible-Sample-TDD", "hosts"=>["192.168.0.103","192.168.0.103"], "user"=>"root", "roles"=>["nginx", "mariadb"]}
# {"name"=>"Ansible-Sample-TDD", "hosts"=>[{"name" => "192.168.0.103:22","uri"=>"192.168.0.103","port"=>22, "private_key"=> "~/.ssh/id_rsa"}], "user"=>"root", "roles"=>["nginx", "mariadb"]}

namespace :serverspec do
  properties.each do |property|
    property["hosts"].each do |host|
      desc "Run serverspec for #{property["name"]}"
      RSpec::Core::RakeTask.new(property["name"].to_sym) do |t|
        puts "Run serverspec for #{property["name"]} to #{host}"
        if host.instance_of?(Hash)
          ENV['TARGET_HOST'] = host["uri"]
          ENV['TARGET_PORT'] = host["port"].to_s
          ENV['TARGET_PRIVATE_KEY'] = host["private_key"]
          unless host["user"].nil?
            ENV['TARGET_USER'] = host["user"]
          else
            ENV['TARGET_USER'] = property["user"]
          end
        else
          ENV['TARGET_HOST'] = host
          ENV['TARGET_PRIVATE_KEY'] = '~/.ssh/id_rsa'
          ENV['TARGET_USER'] = property["user"]
        end
        t.pattern = 'roles/{' + property["roles"].join(',') + '}/spec/*_spec.rb'
      end
    end
  end
end

