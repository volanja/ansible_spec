# coding: utf-8
require 'ansible_spec'

def create_file(name,content)
  File.open(name, 'w') do |f|
    f.puts content
  end
end

def ready_test
  tmp_hosts = 'hosts'
  tmp_ansiblespec = '.ansiblespec'
  tmp_playbook = 'site.yml'

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

#[alias]
#jumper ansible_ssh_port=5555 ansible_ssh_host=192.168.1.50

EOF
  create_file(tmp_ansiblespec,content)
  create_file(tmp_playbook,content_p)
  create_file(tmp_hosts,content_h)
end

describe "load_targetsの実行" do
  context '正常系:複数グループ:変数' do
    tmp_hosts = 'hosts'
    before(:all) do
      ready_test
      @res = AnsibleSpec.load_targets(tmp_hosts)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 1 group' do
      expect(@res.length).to eq 1
    end

    it 'exist group' do
      expect(@res.key?('normal')).to be_truthy
      #expect(@res.key?('alias')).to be_truthy
    end

    it 'normal 192.168.0.1' do
      expect(@res['normal'][0].instance_of?(String)).to be_truthy
      expect(@res['normal'][0]).to eq '192.168.0.1'
    end
    it 'normal 192.168.0.2 ansible_ssh_port=22' do
      expect(@res['normal'][1].instance_of?(Hash)).to be_truthy
      expect(@res['normal'][1]['uri']).to eq '192.168.0.2'
      expect(@res['normal'][1]['port']).to eq 22
    end
    it 'normal 192.168.0.3:5309' do
      expect(@res['normal'][2].instance_of?(Hash)).to be_truthy
      expect(@res['normal'][2]['uri']).to eq '192.168.0.3'
      expect(@res['normal'][2]['port']).to eq 5309
    end
    it '192.168.0.4 ansible_ssh_private_key_file=~/.ssh/id_rsa' do
      expect(@res['normal'][3].instance_of?(Hash)).to be_truthy
      expect(@res['normal'][3]['uri']).to eq '192.168.0.4'
      expect(@res['normal'][3]['port']).to eq 22
      expect(@res['normal'][3]['private_key']).to eq '~/.ssh/id_rsa'
    end

    after(:all) do
      File.delete(tmp_hosts)
    end
  end
end

describe "get_propertiesの実行" do
    require 'yaml'
    tmp_ansiblespec = '.ansiblespec'
    tmp_playbook = 'site.yml'
    tmp_hosts = 'hosts'

    before(:all) do
      ready_test
      @res = AnsibleSpec.get_properties
    end

  context '正常系' do
    it 'res is array' do
      expect(@res.instance_of?(Array)).to be_truthy
    end

    it 'res[0] is hash' do
      expect(@res[0].instance_of?(Hash)).to be_truthy
    end

    it 'check 1 group' do
      expect(@res[0].length).to eq 4
    end

    it 'exist name' do
      expect(@res[0].key?('name')).to be_truthy
      expect(@res[0]['name']).to eq 'Ansible-Sample-TDD'
    end

    it 'normal 192.168.0.1' do
      expect(@res[0]['hosts'].instance_of?(Array)).to be_truthy
      expect(@res[0]['hosts'][0]).to eq '192.168.0.1'
    end

    it 'normal 192.168.0.2 ansible_ssh_port=22' do
      expect(@res[0]['hosts'][1].instance_of?(Hash)).to be_truthy
      expect(@res[0]['hosts'][1]['uri']).to eq '192.168.0.2'
      expect(@res[0]['hosts'][1]['port']).to eq 22
    end

    it 'normal 192.168.0.3:5309' do
      expect(@res[0]['hosts'][2].instance_of?(Hash)).to be_truthy
      expect(@res[0]['hosts'][2]['uri']).to eq '192.168.0.3'
      expect(@res[0]['hosts'][2]['port']).to eq 5309
    end
    it 'normal 192.168.0.4 ansible_ssh_private_key_file=~/.ssh/id_rsa' do
      expect(@res[0]['hosts'][3].instance_of?(Hash)).to be_truthy
      expect(@res[0]['hosts'][3]['uri']).to eq '192.168.0.4'
      expect(@res[0]['hosts'][3]['port']).to eq 22
      expect(@res[0]['hosts'][3]['private_key']).to eq '~/.ssh/id_rsa'
    end

    it 'exist user' do
      expect(@res[0].key?('user')).to be_truthy
      expect(@res[0]['user']).to eq 'root'
    end

    it 'exist roles' do
      expect(@res[0].key?('roles')).to be_truthy
      expect(@res[0]['roles'].instance_of?(Array)).to be_truthy
      expect(@res[0]['roles'][0]).to eq 'nginx'
      expect(@res[0]['roles'][1]).to eq 'mariadb'
    end

    after(:all) do
      File.delete(tmp_ansiblespec)
      File.delete(tmp_playbook)
      File.delete(tmp_hosts)
    end
  end
end
