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
node ansible_ssh_port=4444 ansible_ssh_host=192.168.1.55
node1 ansible_port=4444 ansible_host=192.168.1.55

[normal]
192.168.0.1
192.168.0.2 ansible_ssh_port=22
192.168.0.3:5309
192.168.0.4 ansible_ssh_private_key_file=~/.ssh/id_rsa
192.168.0.5 ansible_ssh_user=git
jumper ansible_ssh_port=5555 ansible_ssh_host=192.168.1.50
node
# Ansible 2.0
192.168.10.2 ansible_port=2222
192.168.10.5 ansible_user=git
jumper2 ansible_port=5555 ansible_host=192.168.10.50
node1
EOF

  create_file(tmp_ansiblespec,content)
  create_file(tmp_playbook,content_p)
  create_file(tmp_hosts,content_h)
end

describe "load_targetsの実行" do
  context '正常系:複数グループ:変数' do
    tmp_hosts = 'hosts'
    before do
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
    end

    it 'normal 192.168.0.1' do
      obj = @res['normal'][0]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj['uri']).to eq '192.168.0.1'
      expect(obj['port']).to eq 22
    end
    it 'normal 192.168.0.2 ansible_ssh_port=22' do
      obj = @res['normal'][1]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj['uri']).to eq '192.168.0.2'
      expect(obj['port']).to eq 22
    end
    it 'normal 192.168.0.3:5309' do
      obj = @res['normal'][2]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj['uri']).to eq '192.168.0.3'
      expect(obj['port']).to eq 5309
    end
    it '192.168.0.4 ansible_ssh_private_key_file=~/.ssh/id_rsa' do
      obj = @res['normal'][3]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj['uri']).to eq '192.168.0.4'
      expect(obj['port']).to eq 22
      expect(obj['private_key']).to eq '~/.ssh/id_rsa'
    end

    it '192.168.0.5 ansible_ssh_user=git' do
      obj = @res['normal'][4]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj['uri']).to eq '192.168.0.5'
      expect(obj['port']).to eq 22
      expect(obj['user']).to eq 'git'
    end

    it 'jumper ansible_ssh_port=5555 ansible_ssh_host=192.168.1.50' do
      obj = @res['normal'][5]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj['name']).to eq 'jumper ansible_ssh_port=5555 ansible_ssh_host=192.168.1.50'
      expect(obj['uri']).to eq '192.168.1.50'
      expect(obj['port']).to eq 5555
    end

    it 'node ansible_ssh_port=4444 ansible_ssh_host=192.168.1.55' do
      obj = @res['normal'][6]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj['name']).to eq 'node ansible_ssh_port=4444 ansible_ssh_host=192.168.1.55'
      expect(obj['uri']).to eq '192.168.1.55'
      expect(obj['port']).to eq 4444
    end

    it '192.168.10.2 ansible_port=2222' do
      obj = @res['normal'][7]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj['uri']).to eq '192.168.10.2'
      expect(obj['port']).to eq 2222
    end

    it '192.168.10.5 ansible_user=git' do
      obj = @res['normal'][8]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj['uri']).to eq '192.168.10.5'
      expect(obj['user']).to eq 'git'
    end

    it 'jumper2 ansible_port=5555 ansible_host=192.168.10.50' do
      obj = @res['normal'][9]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj['name']).to eq 'jumper2 ansible_port=5555 ansible_host=192.168.10.50'
      expect(obj['uri']).to eq '192.168.10.50'
      expect(obj['port']).to eq 5555
    end

    it 'node1 ansible_port=4444 ansible_host=192.168.1.55' do
      obj = @res['normal'][10]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj['name']).to eq 'node1 ansible_port=4444 ansible_host=192.168.1.55'
      expect(obj['uri']).to eq '192.168.1.55'
      expect(obj['port']).to eq 4444
    end
    after do
      File.delete(tmp_hosts)
    end
  end
end

describe "get_propertiesの実行" do
    require 'yaml'
    tmp_ansiblespec = '.ansiblespec'
    tmp_playbook = 'site.yml'
    tmp_hosts = 'hosts'

    before do
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

    it 'check 6 group' do
      expect(@res[0].length).to eq 6
    end

    it 'exist name' do
      expect(@res[0].key?('name')).to be_truthy
      expect(@res[0]['name']).to eq 'Ansible-Sample-TDD'
    end

    it 'normal 192.168.0.1' do
      expect(@res[0]['hosts'].instance_of?(Array)).to be_truthy
      expect(@res[0]['hosts'][0]).to include({'name' => '192.168.0.1',
                                              'uri' => '192.168.0.1',
                                              'port' => 22})
    end

    it 'normal 192.168.0.2 ansible_ssh_port=22' do
      obj = @res[0]['hosts'][1]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj['uri']).to eq '192.168.0.2'
      expect(obj['port']).to eq 22
    end

    it 'normal 192.168.0.3:5309' do
      obj = @res[0]['hosts'][2]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj['uri']).to eq '192.168.0.3'
      expect(obj['port']).to eq 5309
    end
    it 'normal 192.168.0.4 ansible_ssh_private_key_file=~/.ssh/id_rsa' do
      obj = @res[0]['hosts'][3]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj['uri']).to eq '192.168.0.4'
      expect(obj['port']).to eq 22
      expect(obj['private_key']).to eq '~/.ssh/id_rsa'
    end

    it '192.168.0.5 ansible_ssh_user=git' do
      obj = @res[0]['hosts'][4]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj['uri']).to eq '192.168.0.5'
      expect(obj['port']).to eq 22
      expect(obj['user']).to eq 'git'
    end

    it 'jumper ansible_ssh_port=5555 ansible_ssh_host=192.168.1.50' do
      obj = @res[0]['hosts'][5]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj['name']).to eq 'jumper ansible_ssh_port=5555 ansible_ssh_host=192.168.1.50'
      expect(obj['uri']).to eq '192.168.1.50'
      expect(obj['port']).to eq 5555
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

    after do
      File.delete(tmp_ansiblespec)
      File.delete(tmp_playbook)
      File.delete(tmp_hosts)
    end
  end
end
