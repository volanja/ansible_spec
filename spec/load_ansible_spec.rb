# coding: utf-8
require 'ansible_spec'

def create_file(name,content)
  File.open(name, 'w') do |f|
    f.puts content
  end
end

describe "load_targetsの実行" do
  context '正常系:1グループ' do
    tmp_hosts = 'hosts'
    before do
      content = <<'EOF'
[server]
192.168.0.1
192.168.0.2
example.com

EOF
      create_file(tmp_hosts,content)
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

    after do
      File.delete(tmp_hosts)
    end
  end

  context '正常系:2グループ' do
    tmp_hosts = 'hosts'
    before do
      content = <<'EOF'
[web]
192.168.0.3
192.168.0.4

[db]
192.168.0.5
192.168.0.6

EOF
      create_file(tmp_hosts,content)
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

    after do
      File.delete(tmp_hosts)
    end
  end

  context '正常系:1グループ www[01:50].example.com' do
    tmp_hosts = 'hosts'
    before do
      content = <<'EOF'
[web]
www[01:50].example.com
[databases]
db-[a:f].example.com
EOF
      create_file(tmp_hosts,content)
      @res = AnsibleSpec.load_targets(tmp_hosts)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'check 1 group' do
      expect(@res.length).to eq 2
    end

    it 'check group name' do
      expect(@res.key?('web')).to be_truthy
      expect(@res.key?('databases')).to be_truthy
    end

    it 'www[01:50].example.com' do
      1.upto(50){|n|
        leading_zero = n.to_s.rjust(2, '0')
        expect(@res['web']["#{n - 1}".to_i]).to eq "www#{leading_zero}.example.com"
      }
    end

    it 'db-[a:f].example.com' do
      alphabet = [*'a'..'f'] # Array splat
      alphabet.each_with_index {|word, i|
        expect(@res['databases'][i]).to eq "db-#{word}.example.com"
      }
    end

    after do
      File.delete(tmp_hosts)
    end
  end

  context '異常系:全てコメントアウトされている状態' do
    tmp_hosts = 'hosts'
    before do
      content = <<'EOF'
#[server]
#192.168.0.1

EOF
      create_file(tmp_hosts,content)
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

    after do
      File.delete(tmp_hosts)
    end
  end

  context '異常系:ファイル内が空の状態' do
    tmp_hosts = 'hosts'
    before do
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

    after do
      File.delete(tmp_hosts)
    end
  end

  context '異常系:1行だけコメントアウトされている状態' do
    tmp_hosts = 'hosts'
    before do
      content = <<'EOF'
[server]
#192.168.0.10
192.168.0.11

EOF
      create_file(tmp_hosts,content)
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

    after do
      File.delete(tmp_hosts)
    end
  end

  context '異常系:グループ名のみコメントアウトされている状態' do
    tmp_hosts = 'hosts'
    before do
      content = <<'EOF'
[web]
192.168.0.3
#[server]
192.168.0.4

EOF
      create_file(tmp_hosts,content)
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

    after do
      File.delete(tmp_hosts)
    end
  end

  context '正常系:複数グループ:Children in Group' do
    tmp_hosts = 'hosts'
    before do
      content_h = <<'EOF'
[server]
192.168.0.103
192.168.0.104 ansible_ssh_port=22

[databases]
192.168.0.105
192.168.0.106 ansible_ssh_port=5555

[pg:children]
server
databases
EOF
      create_file(tmp_hosts,content_h)
      @res = AnsibleSpec.load_targets(tmp_hosts)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 1 group' do
      expect(@res.length).to eq 3
    end

    it 'exist group' do
      expect(@res.key?('server')).to be_truthy
      expect(@res.key?('databases')).to be_truthy
      expect(@res.key?('pg')).to be_truthy
      expect(@res.key?('pg:children')).not_to be_truthy
    end

    it 'pg 192.168.0.103' do
      obj = @res['pg'][0]
      expect(obj.instance_of?(String)).to be_truthy
      expect(obj).to eq '192.168.0.103'
    end

    it 'pg 192.168.0.104 ansible_ssh_port=22' do
      obj = @res['pg'][1]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj['name']).to eq '192.168.0.104 ansible_ssh_port=22'
      expect(obj['uri']).to eq '192.168.0.104'
      expect(obj['port']).to eq 22
    end

    it 'pg 192.168.0.105' do
      obj = @res['pg'][2]
      expect(obj.instance_of?(String)).to be_truthy
      expect(obj).to eq '192.168.0.105'
    end

    it 'pg 192.168.0.106 ansible_ssh_port=5555' do
      obj = @res['pg'][3]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj['name']).to eq '192.168.0.106 ansible_ssh_port=5555'
      expect(obj['uri']).to eq '192.168.0.106'
      expect(obj['port']).to eq 5555
    end

    after do
      File.delete(tmp_hosts)
    end
  end

end

describe "load_playbookの実行" do
  context '正常系' do
    require 'yaml'
    tmp_pb = 'playbook'
    before do
      content = <<'EOF'
- name: Ansible-Sample-TDD
  hosts: server
  user: root
  roles:
    - nginx
    - mariadb
EOF
      create_file(tmp_pb,content)
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

    after do
      File.delete(tmp_pb)
    end
  end

  context '正常系(nest roles)' do
    require 'yaml'
    tmp_pb = 'playbook'
    before do
      content = <<'EOF'
- name: Ansible-Sample-TDD
  hosts: server
  user: root
  roles:
  - role: nginx
  - role: mariadb
EOF
      create_file(tmp_pb,content)
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

    after do
      File.delete(tmp_pb)
    end
  end

  context '正常系(nest roles)' do
    require 'yaml'
    tmp_pb = 'playbook'
    before do
      content = <<'EOF'
- name: Ansible-Sample-TDD
  hosts: server
  user: root
  roles:
  - common
  - { role: nginx, dir: '/opt/a',  port: 5001 }
  - { role: mariadb, dir: '/opt/b',  port: 5002 }
EOF
      create_file(tmp_pb,content)
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
      expect(@res[0]['roles'][0]).to eq 'common'
      expect(@res[0]['roles'][1]).to eq 'nginx'
      expect(@res[0]['roles'][2]).to eq 'mariadb'
    end

    after do
      File.delete(tmp_pb)
    end
  end

  context '正常系(include)' do
    require 'yaml'
    tmp_pb = 'site.yml'
    tmp_inc = 'nginx.yml'
    before do
      content_pb = <<'EOF'
- name: Ansible-Sample-TDD
  hosts: server
  user: root
  roles:
    - mariadb
- include: nginx.yml
- include: nginx.yml with=params
EOF
      create_file(tmp_pb,content_pb)

      content_inc = <<'EOF'
- name: Ansible-Nginx
  hosts: web
  user: nginx
  roles:
    - nginx
EOF
      create_file(tmp_inc,content_inc)

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
    after do
      File.delete(tmp_pb)
      File.delete(tmp_inc)
    end
  end

  context '異常系(playbookファイルの中身がない場合)' do
    require 'yaml'
    tmp_pb = 'playbook'
    before do
      content = <<'EOF'
EOF
      create_file(tmp_pb,content)
    end

    it 'exitする' do
      expect{ AnsibleSpec.load_playbook(tmp_pb) }.to raise_error(SystemExit)
      # TODO
      # 標準出力のメッセージまでテストしたいが、exitしてしまう。
      #expect{ AnsibleSpec.load_playbook(tmp_pb) }.to output("Error: No data in site.yml").to_stdout
    end

    after do
      File.delete(tmp_pb)
    end
  end

  context '異常系(playbook内にnameがない場合)' do
    require 'yaml'
    tmp_pb = 'playbook'
    before do
      content = <<'EOF'
- hosts: server
  user: root
  roles:
    - nginx
    - mariadb
EOF
      create_file(tmp_pb,content)
    end

    it 'exitする' do
      expect{ AnsibleSpec.load_playbook(tmp_pb) }.to raise_error("Please insert name on playbook")
    end

    after do
      File.delete(tmp_pb)
    end
  end
end

describe "name_exist?の実行" do
  context '正常系' do
    before do
      h = Hash.new
      h["name"] = "test"
      ar = Array.new
      ar << h
      @res_t = AnsibleSpec.name_exist?(ar)
    end

    it 'res_t is true' do
      expect(@res_t).to be_truthy
    end
  end

  context '異常系' do
    before do
      h = Hash.new
      h["var"] = "test"
      ar = Array.new
      ar << h
      @res_f = AnsibleSpec.name_exist?(ar)
    end

    it 'res_f is false' do
      expect(@res_f).to be_falsey
    end
  end
end

describe "#load_ansiblespec" do
  context 'load fallback variables if no .ansiblespec file exists and no ENV vars given' do
    require 'yaml'
    tmp_playbook = 'site.yml'
    tmp_hosts = 'hosts'

    before do
      create_file(tmp_playbook,'')
      create_file(tmp_hosts,'')
      @playbook, @inventoryfile = AnsibleSpec.load_ansiblespec()
    end

    it "playbook is #{tmp_playbook}" do
      expect(@playbook).to eq tmp_playbook
    end

    it "inventoryfile is #{tmp_hosts}" do
      expect(@inventoryfile).to eq tmp_hosts
    end

    after do
      ENV.delete('PLAYBOOK')
      ENV.delete('INVENTORY')
      File.delete(tmp_playbook)
      File.delete(tmp_hosts)
    end
  end

  context 'Use .ansiblespec file when present' do
    require 'yaml'
    tmp_ansiblespec = '.ansiblespec'
    tmp_playbook = 'something.yml'
    tmp_hosts = 'other_hosts'

    before do

      content = <<'EOF'
---
-
  playbook: something.yml
  inventory: other_hosts
EOF
      create_file(tmp_ansiblespec,content)
      create_file(tmp_playbook,'')
      create_file(tmp_hosts,'')
      @playbook, @inventoryfile = AnsibleSpec.load_ansiblespec()
    end

    it "playbook is #{tmp_playbook}" do
      expect(@playbook).to eq tmp_playbook
    end

    it "inventoryfile is #{tmp_hosts}" do
      expect(@inventoryfile).to eq tmp_hosts
    end

    after do
      File.delete(tmp_ansiblespec)
      File.delete(tmp_playbook)
      File.delete(tmp_hosts)
    end
  end

  context 'Overwriting config variables found in file with ENV variables' do
    require 'yaml'
    tmp_ansiblespec = '.ansiblespec'
    tmp_playbook = 'site.yml'
    tmp_hosts = 'hosts'
    env_playbook = 'site_env.yml'
    env_hosts = 'hosts_env'

    content = <<'EOF'
---
-
  playbook: site.yml
  inventory: hosts
EOF

    before do
      ENV['PLAYBOOK'] = env_playbook
      ENV['INVENTORY'] = env_hosts
      create_file(tmp_ansiblespec, content)
      create_file(tmp_playbook,'')
      create_file(tmp_hosts,'')
      create_file(env_playbook,'')
      create_file(env_hosts,'')
      @playbook, @inventoryfile = AnsibleSpec.load_ansiblespec()
    end

    it "playbook is #{env_playbook}" do
      expect(@playbook).to eq env_playbook
    end

    it "inventoryfile is #{env_hosts}" do
      expect(@inventoryfile).to eq env_hosts
    end

    after do
      ENV.delete('PLAYBOOK')
      ENV.delete('INVENTORY')
      File.delete(tmp_ansiblespec)
      File.delete(tmp_playbook)
      File.delete(tmp_hosts)
      File.delete(env_playbook)
      File.delete(env_hosts)
    end
  end

  context 'Use fallback values if file is not present and no ENV vars given' do
    require 'yaml'
    tmp_playbook = 'site.yml'
    tmp_hosts = 'hosts'

    before do
      create_file(tmp_playbook,'')
      create_file(tmp_hosts,'')
      @playbook, @inventoryfile = AnsibleSpec.load_ansiblespec()
    end

    it "playbook is #{tmp_playbook}" do
      expect(@playbook).to eq tmp_playbook
    end

    it "inventoryfile is #{tmp_hosts}" do
      expect(@inventoryfile).to eq tmp_hosts
    end

    after do
      File.delete(tmp_playbook)
      File.delete(tmp_hosts)
    end
  end

  context '異常系(環境変数PLAYBOOKがないので初期値を使う)' do
    require 'yaml'
    tmp_playbook = 'site.yml'
    tmp_hosts = 'hosts'
    env_hosts = 'hosts_env'

    before do
      ENV['INVENTORY'] = tmp_hosts
      create_file(tmp_playbook,'')
      create_file(tmp_hosts,'')
      @playbook, @inventoryfile = AnsibleSpec.load_ansiblespec()
    end

    it "playbook is #{tmp_playbook}" do
      expect(@playbook).to eq tmp_playbook
    end

    it "inventoryfile is #{tmp_hosts}" do
      expect(@inventoryfile).to eq tmp_hosts
    end

    after do
      ENV.delete('INVENTORY')
      File.delete(tmp_playbook)
      File.delete(tmp_hosts)
    end
  end

  context '異常系(環境変数INVENTORYがないので初期値を使う)' do
    require 'yaml'
    tmp_playbook = 'site.yml'
    tmp_hosts = 'hosts'
    env_playbook = 'site_env.yml'

    before do
      ENV['PLAYBOOK'] = tmp_playbook
      create_file(tmp_playbook,'')
      create_file(tmp_hosts,'')
      @playbook, @inventoryfile = AnsibleSpec.load_ansiblespec()
    end

    it "playbook is #{tmp_playbook}" do
      expect(@playbook).to eq tmp_playbook
    end

    it "inventoryfile is #{tmp_hosts}" do
      expect(@inventoryfile).to eq tmp_hosts
    end

    after do
      ENV.delete('PLAYBOOK')
      File.delete(tmp_playbook)
      File.delete(tmp_hosts)
    end
  end

  context 'Use ENV variable to overwrite just one variable (playbook)' do
    require 'yaml'
    tmp_ansiblespec = '.ansiblespec'
    tmp_playbook = 'site_spec.yml'
    tmp_hosts = 'hosts_spec'
    env_playbook = 'site_env.yml'
    env_hosts = 'hosts_env'

    before do
      ENV['PLAYBOOK'] = env_playbook
      content = <<'EOF'
---
-
  playbook: site_spec.yml
  inventory: hosts_spec
EOF
      create_file(tmp_ansiblespec,content)
      create_file(tmp_playbook,'')
      create_file(tmp_hosts,'')
      create_file(env_playbook,'')
      create_file(env_hosts,'')
      @playbook, @inventoryfile = AnsibleSpec.load_ansiblespec()
    end

    it "playbook is #{env_playbook}" do
      expect(@playbook).to eq env_playbook
    end

    it "inventoryfile is #{tmp_hosts}" do
      expect(@inventoryfile).to eq tmp_hosts
    end

    after do
      ENV.delete('PLAYBOOK')
      File.delete(tmp_ansiblespec)
      File.delete(tmp_playbook)
      File.delete(tmp_hosts)
      File.delete(env_playbook)
      File.delete(env_hosts)
    end
  end

  context 'Raise error if playbook and inventory file do not exist' do
    require 'yaml'

    before do
      ENV['PLAYBOOK'] = 'site_env.yml'
      ENV['INVENTORY'] = 'hosts_env'
    end

    it 'exitする' do
      expect{ AnsibleSpec.load_ansiblespec }.to raise_error
    end

    after do
      ENV.delete('PLAYBOOK')
      ENV.delete('INVENTORY')
    end
  end

  context '異常系(.ansiblespecとsite.ymlがないが、hostsがある場合)' do
    require 'yaml'
    tmp_hosts = 'hosts'

    before do
      create_file(tmp_hosts,'')
    end

    it 'exitする' do
      expect{ AnsibleSpec.load_ansiblespec }.to raise_error
    end

    after do
      File.delete(tmp_hosts)
    end
  end

  context '異常系(.ansiblespecとhostsがないが、site.ymlがある場合)' do
    require 'yaml'
    tmp_playbook = 'site.yml'

    before do
      create_file(tmp_playbook,'')
    end

    it 'exitする' do
      expect{ AnsibleSpec.load_ansiblespec }.to raise_error
    end

    after do
      File.delete(tmp_playbook)
    end
  end

end

describe "get_propertiesの実行" do
  context '正常系' do
    require 'yaml'
    tmp_ansiblespec = '.ansiblespec'
    tmp_playbook = 'site.yml'
    tmp_hosts = 'hosts'

    before do

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

      create_file(tmp_ansiblespec,content)
      create_file(tmp_playbook,content_p)
      create_file(tmp_hosts,content_h)
      @res = AnsibleSpec.get_properties
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
      expect(@res[0]['hosts'].instance_of?(Array)).to be_truthy
      expect(@res[0]['hosts'][0]).to eq '192.168.0.103'
      expect(@res[0]['hosts'][1]).to eq '192.168.0.104'
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

  context '正常系 (hosts is all)' do
    require 'yaml'
    tmp_ansiblespec = '.ansiblespec'
    tmp_playbook = 'site.yml'
    tmp_hosts = 'hosts'

    before do

      content = <<'EOF'
---
-
  playbook: site.yml
  inventory: hosts
EOF

      content_p = <<'EOF'
- name: Ansible-Sample-TDD
  hosts: all
  user: root
  roles:
    - nginx
    - mariadb
EOF

      content_h = <<'EOF'
[server]
192.168.0.103
192.168.0.104
[server2]
192.168.0.105
192.168.0.106
EOF

      create_file(tmp_ansiblespec,content)
      create_file(tmp_playbook,content_p)
      create_file(tmp_hosts,content_h)
      @res = AnsibleSpec.get_properties
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
      expect(@res[0]['hosts'].instance_of?(Array)).to be_truthy
      expect(['192.168.0.103','192.168.0.104','192.168.0.105','192.168.0.106']).to match_array(@res[0]['hosts'])
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

  context 'Add hostslist for localhost string' do
    require 'yaml'
    tmp_ansiblespec = '.ansiblespec'
    tmp_playbook = 'site.yml'
    tmp_hosts = 'hosts'

    before do
      content = <<'EOF'
---
-
  playbook: site.yml
  inventory: hosts
EOF

      content_p = <<'EOF'
- name: Ansible-Sample-TDD
  hosts: localhost
  user: root
  roles:
    - nginx
    - mariadb
EOF

      content_h = <<'EOF'
[server]
192.168.0.103
[localhost]
127.0.0.1
EOF

      create_file(tmp_ansiblespec,content)
      create_file(tmp_playbook,content_p)
      create_file(tmp_hosts,content_h) # content ignored in this test
    end

    it 'add array to hosts' do
      expect(AnsibleSpec.get_properties[0]["hosts"]).to eq(['127.0.0.1'])
    end

    after do
      File.delete(tmp_ansiblespec)
      File.delete(tmp_playbook)
      File.delete(tmp_hosts)
    end
  end


  context 'hostgroup not defined in inventory' do
    require 'yaml'
    tmp_ansiblespec = '.ansiblespec'
    tmp_playbook = 'site.yml'
    tmp_hosts = 'hosts'

    before do

      content = <<'EOF'
---
-
  playbook: site.yml
  inventory: hosts
EOF

      content_p = <<'EOF'
- name: Ansible-Sample-TDD
  hosts: match
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

      create_file(tmp_ansiblespec,content)
      create_file(tmp_playbook,content_p)
      create_file(tmp_hosts,content_h)
    end

    it 'Skip hostgroups not defined in inventory' do
      expect{ AnsibleSpec.get_properties }.not_to raise_error
    end

    after do
      File.delete(tmp_ansiblespec)
      File.delete(tmp_playbook)
      File.delete(tmp_hosts)
    end
  end

end
