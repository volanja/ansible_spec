# coding: utf-8
require 'fileutils'
require 'ansible_spec'

def create_file(name,content)
  dir = File.dirname(name)
  unless File.directory?(dir)
    FileUtils.mkdir_p(dir)
  end
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
      expect(@res['server'][0]).to include({'uri' => '192.168.0.1',
                                            'name' => '192.168.0.1',
                                            'port' => 22})
    end
    it 'exist 2nd server' do
      expect(@res['server'][1]).to include({'uri' => '192.168.0.2',
                                            'name' => '192.168.0.2',
                                            'port' => 22})
    end
    it 'exist 3rd server' do
      expect(@res['server'][2]).to include({'uri' => 'example.com',
                                            'name' => 'example.com',
                                            'port' => 22})
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
      expect(@res['web'][0]).to include({'name' => '192.168.0.3',
                                         'uri' => '192.168.0.3',
                                         'port' => 22})
    end
    it 'exist 2nd web' do
      expect(@res['web'][1]).to include({'name' => '192.168.0.4',
                                         'uri' => '192.168.0.4',
                                         'port' => 22})
    end
    it 'not exist 3rd web' do
      expect(@res['web'][2]).to eq nil
    end

    #[db]のチェック
    it 'exist [db]' do
      expect(@res.key?('db')).to be_truthy
    end
    it 'exist 1st db' do
      expect(@res['db'][0]).to include({'name' => '192.168.0.5',
                                        'uri' => '192.168.0.5',
                                        'port' => 22})
    end
    it 'exist 2nd db' do
      expect(@res['db'][1]).to include({'name' => '192.168.0.6',
                                        'uri' => '192.168.0.6',
                                        'port' => 22})
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
node[01:20] ansible_ssh_port=2222

[web]
www[01:50].example.com
[databases]
db-[a:f].example.com
[nodes]
node[01:20]
EOF
      create_file(tmp_hosts,content)
      @res = AnsibleSpec.load_targets(tmp_hosts)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'check 1 group' do
      expect(@res.length).to eq 3
    end

    it 'check group name' do
      expect(@res.key?('web')).to be_truthy
      expect(@res.key?('databases')).to be_truthy
    end

    it 'www[01:50].example.com' do
      1.upto(50){|n|
        leading_zero = n.to_s.rjust(2, '0')
        expect(@res['web']["#{n - 1}".to_i]).to include({'name' => "www#{leading_zero}.example.com",
                                                         'uri' => "www#{leading_zero}.example.com",
                                                         'port' => 22})
      }
    end

    it 'db-[a:f].example.com' do
      alphabet = [*'a'..'f'] # Array splat
      alphabet.each_with_index {|word, i|
        expect(@res['databases'][i]).to include ({'name' => "db-#{word}.example.com",
                                                  'uri' => "db-#{word}.example.com",
                                                  'port' => 22})
      }
    end

    it 'node[01:20]' do
      1.upto(20){|n|
        leading_zero = n.to_s.rjust(2, '0')
        expect(@res['nodes']["#{n - 1}".to_i]).to include({'name' => "node#{leading_zero} ansible_ssh_port=2222",
                                                           'uri' => "node#{leading_zero}",
                                                           'port' => 2222})
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
      expect(@res['server'][0]).to include({'name' => '192.168.0.11',
                                            'uri' => '192.168.0.11',
                                            'port' => 22})
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
      expect(@res['web'][0]).to include ({'name' => '192.168.0.3',
                                          'uri' => '192.168.0.3',
                                          'port' => 22})
    end
    it 'exist 2nd web' do
      expect(@res['web'][1]).to include ({'name' => '192.168.0.4',
                                          'uri' => '192.168.0.4',
                                          'port' => 22})
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
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'name' => '192.168.0.103',
                              'uri' => '192.168.0.103',
                              'port' => 22})
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
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'name' => '192.168.0.105',
                              'uri' => '192.168.0.105',
                              'port' => 22})
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

  context 'load_targets:Test invalid return_type' do
    tmp_hosts = 'hosts'
    content_excpetion_msg = "Variable return_type must be value 'groups' or 'groups_parent_child_relationships'"
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
      begin
        @res = AnsibleSpec.load_targets(tmp_hosts, return_type='some_invalid_option')
      rescue ArgumentError => e
        @res = e.message
      end
    end

    it 'res is string' do
      expect(@res.instance_of?(String)).to be_truthy
    end

    it 'exist 1 string' do
      expect(@res.length).to eq content_excpetion_msg.length
    end

    it 'exist string' do
      expect(@res).to include(content_excpetion_msg)
    end

    after do
      File.delete(tmp_hosts)
    end
  end

  context 'load_targets:Return groups; default return_type (="groups")' do
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
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'name' => '192.168.0.103',
                              'uri' => '192.168.0.103',
                              'port' => 22})
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
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'name' => '192.168.0.105',
                              'uri' => '192.168.0.105',
                              'port' => 22})
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

  context 'load_targets:Return groups; return_type="groups"' do
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
      @res = AnsibleSpec.load_targets(tmp_hosts, return_type='groups')
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
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'name' => '192.168.0.103',
                              'uri' => '192.168.0.103',
                              'port' => 22})
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
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'name' => '192.168.0.105',
                              'uri' => '192.168.0.105',
                              'port' => 22})
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

  context 'load_targets:Return groups parent child relationships; return_type="groups_parent_child_relationships"' do
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
      @res = AnsibleSpec.load_targets(tmp_hosts, return_type='groups_parent_child_relationships')
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 1 group parent child relationship in Hash' do
      expect(@res.length).to eq 1
    end

    it 'exist each pair' do
      expect(@res).to include({"pg"=>["server", "databases"]})
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

  %w[include import_playbook].each do |action|
    context "正常系(#{action})" do
      require 'yaml'
      tmp_pb = 'site.yml'
      tmp_inc = 'nginx.yml'
      before do
        content_pb = <<"EOF"  # ヒアドキュメント内で変数展開する時は""(double quote)で囲む。
- name: Ansible-Sample-TDD
  hosts: server
  user: root
  roles:
    - mariadb
- #{action}: nginx.yml
EOF
        create_file(tmp_pb,content_pb)

        content_inc = <<'EOF'
- name: Ansible-Nginx
  hosts: web
  user: nginx
  roles:
    - nginx

- name: Ansible-Nginx2
  hosts: proxies
  user: nginx
  roles:
   - nginx-proxy
EOF
        create_file(tmp_inc,content_inc)

        @res = AnsibleSpec.load_playbook(tmp_pb)
      end

      it 'res is array' do
        expect(@res.instance_of?(Array)).to be_truthy
      end

      it 'res has three groups' do
        expect(@res.length).to eq 3
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

      it 'exist name' do
        expect(@res[2].key?('name')).to be_truthy
        expect(@res[2]['name']).to eq 'Ansible-Nginx2'
      end

      after do
        File.delete(tmp_pb)
        File.delete(tmp_inc)
      end
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
      expect{ AnsibleSpec.load_playbook(tmp_pb) }.to raise_error("Please insert name on playbook 'playbook'")
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


describe "flatten_roleの実行" do
  context '正常系 ["nginx"]' do
    before do
      @res = AnsibleSpec.flatten_role(["nginx"])
    end

    it 'res is array' do
      expect(@res.instance_of?(Array)).to be_truthy
    end

    it 'nginx' do
      expect(@res[0]).to eq 'nginx'
    end
  end

  context '正常系 {"role"=>"nginx"}' do
    before do
      @res = AnsibleSpec.flatten_role([{"role"=>"nginx"}])
    end

    it 'res is array' do
      expect(@res.instance_of?(Array)).to be_truthy
    end

    it 'nginx' do
      expect(@res[0]).to eq 'nginx'
    end
  end

  context '正常系 {"role"=>"nginx", "dir"=>"/opt/b", "port"=>5001}' do
    before do
      @res = AnsibleSpec.flatten_role([{"role"=>"nginx", "dir"=>"/opt/b", "port"=>5001}])
    end

    it 'res is array' do
      expect(@res.instance_of?(Array)).to be_truthy
    end

    it 'nginx' do
      expect(@res[0]).to eq 'nginx'
    end
  end

  context '異常系 nil' do
    before do
      @res = AnsibleSpec.flatten_role([])
    end

    it 'res is array' do
      expect(@res.instance_of?(Array)).to be_truthy
    end

    it 'nil' do
      expect(@res[0]).to eq nil
    end
  end
end

describe "load_ansiblespecの実行" do
  context '正常系(環境変数PLAYBOOK)' do
    require 'yaml'
    tmp_playbook = 'site_env.yml'
    tmp_hosts = 'hosts'

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
      ENV.delete('INVENTORY')
      File.delete(tmp_playbook)
      File.delete(tmp_hosts)
    end
  end

  context '正常系(環境変数INVENTORY)' do
    require 'yaml'
    tmp_playbook = 'site.yml'
    tmp_hosts = 'hosts_env'

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
      ENV.delete('PLAYBOOK')
      ENV.delete('INVENTORY')
      File.delete(tmp_playbook)
      File.delete(tmp_hosts)
    end
  end

  context '正常系(.ansiblespec)' do
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

  context '正常系(.ansiblespecと環境変数がある場合、環境変数が優先される)' do
    require 'yaml'
    tmp_ansiblespec = '.ansiblespec'
    tmp_playbook = 'site.yml'
    tmp_hosts = 'hosts'
    env_playbook = 'site_env.yml'
    env_hosts = 'hosts_env'

    before do
      ENV['PLAYBOOK'] = env_playbook
      ENV['INVENTORY'] = env_hosts
      create_file(tmp_ansiblespec,'')
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

  context '正常系(.ansiblespecと環境変数がないが、site.ymlとhostsがある場合)' do
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

  context '正常系(環境変数PLAYBOOKがないので初期値を使う)' do
    require 'yaml'
    tmp_playbook = 'site.yml'
    tmp_hosts = 'hosts_env'
    env_hosts = 'hosts_env'

    before do
      ENV['INVENTORY'] = env_hosts
      create_file(tmp_playbook,'')
      create_file(tmp_hosts,'')
      @playbook, @inventoryfile = AnsibleSpec.load_ansiblespec()
    end

    it "playbook is #{tmp_playbook}" do
      expect(@playbook).to eq tmp_playbook
    end

    it "inventoryfile is #{env_hosts}" do
      expect(@inventoryfile).to eq env_hosts
    end

    after do
      ENV.delete('INVENTORY')
      File.delete(tmp_playbook)
      File.delete(tmp_hosts)
    end
  end

  context '正常系(環境変数INVENTORYがないので初期値を使う)' do
    require 'yaml'
    tmp_playbook = 'site_env.yml'
    tmp_hosts = 'hosts'
    env_playbook = 'site_env.yml'

    before do
      ENV['PLAYBOOK'] = env_playbook
      create_file(tmp_playbook,'')
      create_file(tmp_hosts,'')
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
      File.delete(tmp_playbook)
      File.delete(tmp_hosts)
    end
  end

  context '正常系(環境変数PLAYBOOKがないのでplaybookは.ansiblespecを使う)' do
    require 'yaml'
    tmp_ansiblespec = '.ansiblespec'
    tmp_playbook = 'site_spec.yml'
    tmp_hosts = 'hosts_spec'
    env_playbook = 'site_env.yml'
    env_hosts = 'hosts_env'

    before do
      ENV['INVENTORY'] = env_hosts
      content = <<'EOF'
---
-
  playbook: site_spec.yml
EOF
      create_file(tmp_ansiblespec,content)
      create_file(tmp_playbook,'')
      create_file(tmp_hosts,'')
      create_file(env_playbook,'')
      create_file(env_hosts,'')
      @playbook, @inventoryfile = AnsibleSpec.load_ansiblespec()
    end

    it "playbook is #{tmp_playbook}" do
      expect(@playbook).to eq tmp_playbook
    end

    it "inventoryfile is #{env_hosts}" do
      expect(@inventoryfile).to eq env_hosts
    end

    after do
      ENV.delete('INVENTORY')
      File.delete(tmp_ansiblespec)
      File.delete(tmp_playbook)
      File.delete(tmp_hosts)
      File.delete(env_playbook)
      File.delete(env_hosts)
    end
  end

  context '正常系(環境変数INVENTORYがないのでinventoryfileは.ansiblespecを使う)' do
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

  context '異常系(環境変数で指定したファイルがない場合)' do
    require 'yaml'

    before do
      ENV['PLAYBOOK'] = 'site_env.yml'
      ENV['INVENTORY'] = 'hosts_env'
    end

    it 'exitする' do
      expect{ AnsibleSpec.load_ansiblespec }.to raise_error(SystemExit)
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
      expect{ AnsibleSpec.load_ansiblespec }.to raise_error(SystemExit)
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
      expect{ AnsibleSpec.load_ansiblespec }.to raise_error(SystemExit)
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

    it 'check 6 group' do
      expect(@res[0].length).to eq 6
    end

    it 'exist name' do
      expect(@res[0].key?('name')).to be_truthy
      expect(@res[0]['name']).to eq 'Ansible-Sample-TDD'
    end

    it 'exist hosts' do
      expect(@res[0]['hosts'].instance_of?(Array)).to be_truthy
      expect(@res[0]['hosts'][0]).to include({'name' => '192.168.0.103',
                                              'uri' => '192.168.0.103',
                                              'port' => 22})
      expect(@res[0]['hosts'][1]).to include({'name' => '192.168.0.104',
                                              'uri' => '192.168.0.104',
                                              'port' => 22})
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

    it 'check 6 group' do
      expect(@res[0].length).to eq 6
    end

    it 'exist name' do
      expect(@res[0].key?('name')).to be_truthy
      expect(@res[0]['name']).to eq 'Ansible-Sample-TDD'
    end

    it 'exist hosts' do
      expect(@res[0]['hosts'].instance_of?(Array)).to be_truthy
      expect([{'name' => '192.168.0.103',
               'uri' => '192.168.0.103',
               'port' => 22},
              {'name' => '192.168.0.104',
               'uri' => '192.168.0.104',
               'port' => 22},
              {'name' => '192.168.0.105',
               'uri' => '192.168.0.105',
               'port' => 22},
              {'name' => '192.168.0.106',
               'uri' => '192.168.0.106',
               'port' => 22}]).to match_array(@res[0]['hosts'])
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

  context 'Incorrect Case: Select invalid hostname' do
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
# miss name of group
[servers]
192.168.0.103
192.168.0.104
EOF

      create_file(tmp_ansiblespec,content)
      create_file(tmp_playbook,content_p)
      create_file(tmp_hosts,content_h)
    end

    it 'not exist hosts.' do
      # output error messages
      expect {AnsibleSpec.get_properties}.to output("no hosts matched for server\n").to_stdout
      @res = AnsibleSpec.get_properties
      expect(@res[0]['hosts'].instance_of?(Array)).to be_truthy
      expect(@res[0]['hosts'].length).to eq 0
    end

    after do
      File.delete(tmp_ansiblespec)
      File.delete(tmp_playbook)
      File.delete(tmp_hosts)
    end
  end

  context '正常系 (hosts 複数指定)' do
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
  hosts:
    -  server
    -  server2
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

    it 'check 6 group' do
      expect(@res[0].length).to eq 6
    end

    it 'exist name' do
      expect(@res[0].key?('name')).to be_truthy
      expect(@res[0]['name']).to eq 'Ansible-Sample-TDD'
    end

    it 'exist hosts' do
      expect(@res[0]['hosts'].instance_of?(Array)).to be_truthy
      expect([{'name' => '192.168.0.103',
               'uri' => '192.168.0.103',
               'port' => 22,
               'hosts'=>'server'},
              {'name' => '192.168.0.104',
               'uri' => '192.168.0.104',
               'port' => 22,
               'hosts'=>'server'},
              {'name' => '192.168.0.105',
               'uri' => '192.168.0.105',
               'port' => 22,
               'hosts'=>'server2'},
              {'name' => '192.168.0.106',
               'uri' => '192.168.0.106',
               'port' => 22,
               'hosts'=>'server2'}]).to match_array(@res[0]['hosts'])
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

  context '正常系 (hosts 複数指定)ホストがグループにない場合タスクをスキップ' do
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
- name: Ansible-Sample-TDD-1
  hosts:
    - server
  user: root
  roles:
    - role: nginx
    - role: mariadb
- name: Ansible-Sample-TDD-3-None-Servers
  hosts:
    - server3
  user: root
  roles:
    - role: nginx
    - role: mariadb
- name: Ansible-Sample-TDD-2
  hosts:
    - server2
  user: root
  roles:
    - role: nginx
    - role: mariadb
EOF

      content_h = <<'EOF'
[server]
192.168.0.103
192.168.0.104
[server3]
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

    it 'check 6 group' do
      expect(@res[0].length).to eq 6
    end

    it 'exist name' do
      expect(@res[0].key?('name')).to be_truthy
      expect(@res[0]['name']).to eq 'Ansible-Sample-TDD-1'
	  # if empty host in target groups(hosts), skip task.
      #expect(@res[1].key?('name')).to be_truthy
      #expect(@res[1]['name']).to eq 'Ansible-Sample-TDD-3-None-Servers'
      expect(@res[1].key?('name')).to be_truthy
      expect(@res[1]['name']).to eq 'Ansible-Sample-TDD-2'
    end

    after do
      File.delete(tmp_ansiblespec)
      File.delete(tmp_playbook)
      File.delete(tmp_hosts)
    end
  end
end
