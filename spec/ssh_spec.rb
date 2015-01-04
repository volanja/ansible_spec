require 'spec_helper'
require 'ansible_spec'
require 'yaml'

set :backend, :ssh

describe 'ssh' do
  context 'with root user' do 
    before do
      create_normality
      properties = AnsibleSpec.get_properties
      @h = Hash.new
      n = 0
      properties.each do |property|
        property["hosts"].each do |host|
          #ENV['TARGET_PRIVATE_KEY'] = '~/.ssh/id_rsa'
          #t.pattern = 'roles/{' + property["roles"].join(',') + '}/spec/*_spec.rb'
          @ssh = double(:ssh)
          if host.instance_of?(Hash)
            set :host, host["uri"]
            set :ssh_options, :user => property["user"], :port => host["port"]
            allow(@ssh).to receive(:port).and_return(Specinfra.configuration.ssh_options[:port])
          else
            set :host, host
            set :ssh_options, :user => property["user"]
          end
          allow(@ssh).to receive(:host).and_return(Specinfra.configuration.host)
          allow(@ssh).to receive(:user).and_return(Specinfra.configuration.ssh_options[:user])
          @h["task_#{n}"] = @ssh
          n += 1
        end
      end
    end

    it '192.168.0.1' do
      v = @h["task_0"]
      expect(v.user).to eq 'root'
      expect(v.host).to eq '192.168.0.1'
    end
    it '192.168.0.2:22' do
      v = @h["task_1"]
      expect(v.user).to eq 'root'
      expect(v.host).to eq '192.168.0.2'
      expect(v.port).to eq 22
    end
    it '192.168.0.3 ansible_ssh_port=22' do
      v = @h["task_2"]
      expect(v.user).to eq 'root'
      expect(v.host).to eq '192.168.0.3'
      expect(v.port).to eq 5309
    end
    after do
      delete_normality
    end
  end
end

def create_normality
  tmp_ansiblespec = '.ansiblespec'
  tmp_playbook = 'site.yml'
  tmp_hosts = 'hosts'

  content = <<'EOF'
---
-
  playbook: site.yml
  inventory: hosts
EOF

  content_p = <<'EOF'
- name: Ansible-Sample-TDD
  hosts: normal
  user: root
  roles:
    - nginx
    - mariadb
EOF

  content_h = <<'EOF'
[normal]
192.168.0.1
192.168.0.2 ansible_ssh_port=22
192.168.0.3:5309

#[variables]
#192.168.0.4

#[variables:vars]
#ansible_ssh_port=22
#ansible_ssh_user=root

#[alias]
#jumper ansible_ssh_port=5555 ansible_ssh_host=192.168.1.50
EOF

  File.open(tmp_ansiblespec, 'w') do |f|
    f.puts content
  end
  File.open(tmp_playbook, 'w') do |f|
    f.puts content_p
  end
  File.open(tmp_hosts, 'w') do |f|
    f.puts content_h
  end
end

def delete_normality
  tmp_ansiblespec = '.ansiblespec'
  tmp_playbook = 'site.yml'
  tmp_hosts = 'hosts'
  File.delete(tmp_ansiblespec)
  File.delete(tmp_playbook)
  File.delete(tmp_hosts)
end
