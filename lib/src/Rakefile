require 'rake'
require 'rspec/core/rake_task'
require 'yaml'
require 'ansible_spec'

properties = AnsibleSpec.get_properties
# {"name"=>"Ansible-Sample-TDD", "hosts"=>["192.168.0.103","192.168.0.103"], "user"=>"root", "roles"=>["nginx", "mariadb"]}
# {"name"=>"Ansible-Sample-TDD", "hosts"=>[{"name" => "192.168.0.103:22","uri"=>"192.168.0.103","port"=>22, "private_key"=> "~/.ssh/id_rsa"}], "user"=>"root", "roles"=>["nginx", "mariadb"]}

namespace :serverspec do
  properties.each_with_index.map do |property, index|
    property["hosts"].each do |host|
      desc "Run serverspec for #{property["name"]}"
      RSpec::Core::RakeTask.new(property["name"].to_sym) do |t|
        puts "Run serverspec for #{property["name"]} to #{host}"
        ENV['TARGET_HOST'] = host["uri"]
        ENV['TARGET_PORT'] = host["port"].to_s
        ENV['TARGET_GROUP_INDEX'] = index.to_s
        ENV['TARGET_PRIVATE_KEY'] = host["private_key"]
        unless host["user"].nil?
          ENV['TARGET_USER'] = host["user"]
        else
          ENV['TARGET_USER'] = property["user"]
        end

        roles = property["roles"]
        for role in property["roles"]
          deps = AnsibleSpec.load_dependencies(role)
          roles += deps
        end
        t.pattern = 'roles/{' + roles.join(',') + '}/spec/*_spec.rb'
      end
    end
  end
end
