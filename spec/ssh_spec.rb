require 'spec_helper'

set :backend, :ssh

describe 'ssh' do
  context 'with root user' do 
    before do
        create_normality
        properties = AnsibleSpec.get_properties
        @h = Hash.new
        n = 0
        properties.each do |var|
          var["hosts"].each do |host|
              #ENV['TARGET_PRIVATE_KEY'] = '~/.ssh/id_rsa'
              #t.pattern = 'roles/{' + var["roles"].join(',') + '}/spec/*_spec.rb'
              set :host, host
              set :ssh_options, :user => var["user"]
              @ssh = double(:ssh)
              allow(@ssh).to receive(:host).and_return(Specinfra.configuration.host)
              allow(@ssh).to receive(:user).and_return(Specinfra.configuration.ssh_options[:user])
              @h["task_#{n}"] = @ssh
              n += 1
          end
        end
    end
    it 'should not prepend sudo' do
      @h.each{|k,v|
        if k == "task_0"
          expect(v.user).to eq 'root'
          expect(v.host).to eq '192.168.0.103'
        elsif k == "task_1"
          expect(v.user).to eq 'root'
          expect(v.host).to eq '192.168.0.104'
        end
      }
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
  hosts: server
  user: root
  roles:
    - nginx
    - mariadb
EOF

  content_h = <<'EOF'
[server]
192.168.0.103
192.168.0.104
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
