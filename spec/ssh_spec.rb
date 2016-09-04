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
          @ssh = set_ssh(property, host)
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
      expect(v.port).to eq '22'
    end
    it '192.168.0.3:5309' do
      v = @h["task_2"]
      expect(v.user).to eq 'root'
      expect(v.host).to eq '192.168.0.3'
      expect(v.port).to eq '5309'
    end
    it '192.168.0.4 ansible_ssh_private_key_file=~/.ssh/id_rsa' do
      v = @h["task_3"]
      expect(v.user).to eq 'root'
      expect(v.host).to eq '192.168.0.4'
      expect(v.port).to eq '22'
      expect(v.keys).to eq '~/.ssh/id_rsa'
    end

    it '192.168.0.5 ansible_ssh_user=git' do
      v = @h["task_4"]
      expect(v.user).to eq 'git'
      expect(v.host).to eq '192.168.0.5'
      expect(v.port).to eq '22'
    end

    it 'jumper ansible_ssh_port=5555 ansible_ssh_host=192.168.1.50' do
      v = @h["task_5"]
      expect(v.user).to eq 'root'
      expect(v.host).to eq '192.168.1.50'
      expect(v.port).to eq '5555'
    end

    it 'www[01:02].example.com' do
      v = @h["task_6"]
      expect(v.user).to eq 'root'
      expect(v.host).to eq 'www01.example.com'
    end

    it 'www[01:02].example.com' do
      v = @h["task_7"]
      expect(v.user).to eq 'root'
      expect(v.host).to eq 'www02.example.com'
    end

    it 'db-[a:b].example.com' do
      v = @h["task_8"]
      expect(v.user).to eq 'root'
      expect(v.host).to eq 'db-a.example.com'
    end

    it 'db-[a:b].example.com' do
      v = @h["task_9"]
      expect(v.user).to eq 'root'
      expect(v.host).to eq 'db-b.example.com'
    end

    it '192.168.1.3 ansible_connection=winrm ansible_ssh_port=5985 ansible_ssh_user=administrator ansible_ssh_pass=Passw0rd' do
      v = @h["task_10"]
      expect(v.host).to eq '192.168.1.3'
      expect(v.user).to eq 'administrator'
      expect(v.port).to eq '5985'
    end

    it '192.168.10.2 ansible_port=2222' do
      v = @h["task_11"]
      expect(v.user).to eq 'root'
      expect(v.host).to eq '192.168.10.2'
      expect(v.port).to eq '2222'
    end

    it '192.168.10.5 ansible_user=git' do
      v = @h["task_12"]
      expect(v.user).to eq 'git'
      expect(v.host).to eq '192.168.10.5'
      expect(v.port).to eq '22'
    end

    it 'jumper2 ansible_port=5555 ansible_host=192.168.10.50' do
      v = @h["task_13"]
      expect(v.user).to eq 'root'
      expect(v.host).to eq '192.168.10.50'
      expect(v.port).to eq '5555'
    end

    after do
      delete_normality
    end
  end
end


describe 'ssh with dynamic inventory' do
  context 'ssh with' do
    before do
      create_dynamic_inventory
      properties = AnsibleSpec.get_properties
      @h = Hash.new
      n = 0
      properties.each do |property|
        property["hosts"].each do |host|
          #t.pattern = 'roles/{' + property["roles"].join(',') + '}/spec/*_spec.rb'
          @ssh = set_ssh(property, host)
          @h["task_#{n}"] = @ssh
          n += 1
        end
      end
    end

    it 'tag_Name_sample_app' do
      v = @h["task_0"]
      expect(v.user).to eq 'root'
      expect(v.host).to eq '54.1.2.3'
      expect(v.port).to eq '22'
    end

    after do
      delete_normality
    end

  end
end

# summary: lib/src/Rakefile
def set_ssh(property, host)
  @ssh = double(:ssh)
  set :host, host["uri"]
  unless host["user"].nil?
    user = host["user"]
  else
    user = property["user"]
  end
  set :ssh_options, :user => user, :port => host["port"].to_s, :keys => host["private_key"]
  allow(@ssh).to receive(:host).and_return(Specinfra.configuration.host)
  allow(@ssh).to receive(:user).and_return(Specinfra.configuration.ssh_options[:user])
  allow(@ssh).to receive(:port).and_return(Specinfra.configuration.ssh_options[:port])
  allow(@ssh).to receive(:keys).and_return(Specinfra.configuration.ssh_options[:keys])
  return @ssh
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
192.168.0.4 ansible_ssh_private_key_file=~/.ssh/id_rsa
192.168.0.5 ansible_ssh_user=git
jumper ansible_ssh_port=5555 ansible_ssh_host=192.168.1.50
www[01:02].example.com
db-[a:b].example.com
192.168.1.3 ansible_connection=winrm ansible_ssh_port=5985 ansible_ssh_user=administrator ansible_ssh_pass=Passw0rd
# Ansible 2.0
192.168.10.2 ansible_port=2222
192.168.10.5 ansible_user=git
jumper2 ansible_port=5555 ansible_host=192.168.10.50
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

def create_dynamic_inventory
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
  hosts: tag_Name_sample_app
  user: root
  roles:
    - nginx
    - mariadb
EOF

  content_h = <<'EOF'
#!/bin/bash
echo '{ "_meta" : {"hostvars": {"54.1.2.3": {"ec2_ip_address": "54.1.2.3","ec2_key_name": "my-secret-key", "ec2_launch_time": "2016-01-06T03:59:56.000Z", "ec2_tag_Name": "sample-app", "ec2_tag_Stack": "sample-app"}}},"tag_Name_sample_app": ["54.1.2.3"]}'
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
  File.chmod(0755,tmp_hosts)
end


def delete_normality
  tmp_ansiblespec = '.ansiblespec'
  tmp_playbook = 'site.yml'
  tmp_hosts = 'hosts'
  File.delete(tmp_ansiblespec)
  File.delete(tmp_playbook)
  File.delete(tmp_hosts)
end
