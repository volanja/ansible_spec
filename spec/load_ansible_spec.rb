# coding: utf-8
require 'ansible_spec'

describe "load_targetsの実行" do
  context '正常系:1グループ' do
    tmp_hosts = 'hosts'
    before(:all) do
      content = <<'EOF'
[server]
192.168.0.1
192.168.0.2
example.com

EOF
      File.open(tmp_hosts, 'w') do |f|
        f.puts content
      end
      @res = AnsibleSpec.load_targets(tmp_hosts)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 1 group' do
      expect(@res.length).to eq 1
    end

    it 'exist [server]' do
      expect(@res.key?('server')).to be_truthy
    end

    it 'exist 1st server' do
      expect(@res['server'][0]).to eq '192.168.0.1'
    end
    it 'exist 2nd server' do
      expect(@res['server'][1]).to eq '192.168.0.2'
    end
    it 'exist 3rd server' do
      expect(@res['server'][2]).to eq 'example.com'
    end
    it 'not exist 4th server' do
      expect(@res['server'][3]).to eq nil
    end

    after(:all) do
      File.delete(tmp_hosts)
    end
  end

  context '正常系:2グループ' do
    tmp_hosts = 'hosts'
    before(:all) do
      content = <<'EOF'
[web]
192.168.0.3
192.168.0.4

[db]
192.168.0.5
192.168.0.6

EOF
      File.open(tmp_hosts, 'w') do |f|
        f.puts content
      end
      @res = AnsibleSpec.load_targets(tmp_hosts)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'check 2 group' do
      expect(@res.length).to eq 2
    end

    #[web]のチェック
    it 'exist [web]' do
      expect(@res.key?('web')).to be_truthy
    end
    it 'exist 1st web' do
      expect(@res['web'][0]).to eq '192.168.0.3'
    end
    it 'exist 2nd web' do
      expect(@res['web'][1]).to eq '192.168.0.4'
    end
    it 'not exist 3rd web' do
      expect(@res['web'][2]).to eq nil
    end

    #[db]のチェック
    it 'exist [db]' do
      expect(@res.key?('db')).to be_truthy
    end
    it 'exist 1st db' do
      expect(@res['db'][0]).to eq '192.168.0.5'
    end
    it 'exist 2nd db' do
      expect(@res['db'][1]).to eq '192.168.0.6'
    end
    it 'not exist 3rd db' do
      expect(@res['db'][2]).to eq nil
    end

    after(:all) do
      File.delete(tmp_hosts)
    end
  end

  context '異常系:全てコメントアウトされている状態' do
    tmp_hosts = 'hosts'
    before(:all) do
      content = <<'EOF'
#[server]
#192.168.0.1

EOF
      File.open(tmp_hosts, 'w') do |f|
        f.puts content
      end
      @res = AnsibleSpec.load_targets(tmp_hosts)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'check 0 group' do
      expect(@res.length).to eq 0
    end

    it 'not exist [server]' do
      expect(@res.key?('server')).not_to be_truthy
    end

    after(:all) do
      File.delete(tmp_hosts)
    end
  end

  context '異常系:ファイル内が空の状態' do
    tmp_hosts = 'hosts'
    before(:all) do
      content = <<'EOF'

EOF
      File.open(tmp_hosts, 'w') do |f|
        f.puts content
      end
      @res = AnsibleSpec.load_targets(tmp_hosts)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'check 0 group' do
      expect(@res.length).to eq 0
    end

    it 'not exist [server]' do
      expect(@res.key?('server')).not_to be_truthy
    end

    after(:all) do
      File.delete(tmp_hosts)
    end
  end

  context '異常系:1行だけコメントアウトされている状態' do
    tmp_hosts = 'hosts'
    before(:all) do
      content = <<'EOF'
[server]
#192.168.0.10
192.168.0.11

EOF
      File.open(tmp_hosts, 'w') do |f|
        f.puts content
      end
      @res = AnsibleSpec.load_targets(tmp_hosts)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'check 1 group' do
      expect(@res.length).to eq 1
    end

    it 'not exist [server]' do
      expect(@res.key?('server')).to be_truthy
    end
    it 'not exist 1st server' do
      expect(@res['server'][0]).not_to eq '192.168.0.10'
    end
    it 'exist 2nd server' do
      expect(@res['server'][0]).to eq '192.168.0.11'
    end

    after(:all) do
      File.delete(tmp_hosts)
    end
  end

  context '異常系:グループ名のみコメントアウトされている状態' do
    tmp_hosts = 'hosts'
    before(:all) do
      content = <<'EOF'
[web]
192.168.0.3
#[server]
192.168.0.4

EOF
      File.open(tmp_hosts, 'w') do |f|
        f.puts content
      end
      @res = AnsibleSpec.load_targets(tmp_hosts)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'check 1 group' do
      expect(@res.length).to eq 1
    end

    it 'exist [web]' do
      expect(@res.key?('web')).to be_truthy
    end
    it 'exist 1st web' do
      expect(@res['web'][0]).to eq '192.168.0.3'
    end
    it 'exist 2nd web' do
      expect(@res['web'][1]).to eq '192.168.0.4'
    end

    after(:all) do
      File.delete(tmp_hosts)
    end
  end

  context '正常系' do
    require 'yaml'
    tmp_pb = 'playbook'
    before(:all) do
      content = <<'EOF'
- name: Ansible-Sample-TDD
  hosts: server
  user: root
  roles:
    - nginx
    - mariadb
EOF
      File.open(tmp_pb, 'w') do |f|
        f.puts content
      end
      @res = AnsibleSpec.load_playbook(tmp_pb)
    end

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

    it 'exist hosts' do
      expect(@res[0].key?('hosts')).to be_truthy
      expect(@res[0]['hosts']).to eq 'server'
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
      File.delete(tmp_pb)
    end
  end

  context '正常系(include)' do
    require 'yaml'
    tmp_pb = 'site.yml'
    tmp_inc = 'nginx.yml'
    before(:all) do
      content_pb = <<'EOF'
- name: Ansible-Sample-TDD
  hosts: server
  user: root
  roles:
    - mariadb
- include: nginx.yml
EOF
      File.open(tmp_pb, 'w') do |f|
        f.puts content_pb
      end

      content_inc = <<'EOF'
- name: Ansible-Nginx
  hosts: web
  user: nginx
  roles:
    - nginx
EOF
      File.open(tmp_inc, 'w') do |f|
        f.puts content_inc
      end

      @res = AnsibleSpec.load_playbook(tmp_pb)
    end

    it 'res is array' do
      expect(@res.instance_of?(Array)).to be_truthy
    end

    it 'res is hash' do
      expect(@res[0].instance_of?(Hash)).to be_truthy
    end

    it 'check 1 group' do
      expect(@res[0].length).to eq 4
    end

    it 'exist name' do
      expect(@res[0].key?('name')).to be_truthy
      expect(@res[0]['name']).to eq 'Ansible-Sample-TDD'
    end

    it 'exist hosts' do
      expect(@res[0].key?('hosts')).to be_truthy
      expect(@res[0]['hosts']).to eq 'server'
    end

    it 'exist user' do
      expect(@res[0].key?('user')).to be_truthy
      expect(@res[0]['user']).to eq 'root'
    end

    it 'exist roles' do
      expect(@res[0].key?('roles')).to be_truthy
      expect(@res[0]['roles'].instance_of?(Array)).to be_truthy
      expect(@res[0]['roles'][0]).to eq 'mariadb'
    end

    # - include: nginx.yml
    it 'res is hash' do
      expect(@res[1].instance_of?(Hash)).to be_truthy
    end

    it 'check 1 group' do
      expect(@res[1].length).to eq 4
    end

    it 'exist name' do
      expect(@res[1].key?('name')).to be_truthy
      expect(@res[1]['name']).to eq 'Ansible-Nginx'
    end

    it 'exist hosts' do
      expect(@res[1].key?('hosts')).to be_truthy
      expect(@res[1]['hosts']).to eq 'web'
    end

    it 'exist user' do
      expect(@res[1].key?('user')).to be_truthy
      expect(@res[1]['user']).to eq 'nginx'
    end

    it 'exist roles' do
      expect(@res[1].key?('roles')).to be_truthy
      expect(@res[1]['roles'].instance_of?(Array)).to be_truthy
      expect(@res[1]['roles'][0]).to eq 'nginx'
    end
    after(:all) do
      File.delete(tmp_pb)
      File.delete(tmp_inc)
    end
  end
end
