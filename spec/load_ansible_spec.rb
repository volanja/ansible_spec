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
end
