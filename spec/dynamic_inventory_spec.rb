# coding: utf-8
require 'ansible_spec'

describe "load_targetsの実行" do
  context '正常系:DynamicInventory:1 Group, 1 hosts' do
    tmp_hosts = 'hosts'
    before do
      content_h = <<'EOF'
#!/bin/bash
echo '{"databases": {"hosts": ["host1.example.com"],"vars":{"a": true}}}'
EOF
      create_file(tmp_hosts,content_h)
      File.chmod(0755,tmp_hosts)
      @res = AnsibleSpec.load_targets(tmp_hosts)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 2 group' do
      expect(@res.length).to eq 2
    end

    it 'exist group' do
      expect(@res.key?('databases')).to be_truthy
      expect(@res.key?('hosts_childrens')).to be_truthy
    end

    it 'databases host1.example.com' do
      obj = @res['databases'][0]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'uri' => 'host1.example.com',
                              'port' => 22})
    end

    after do
      File.delete(tmp_hosts)
    end
  end

  context '正常系:DynamicInventory:1 Group, 2 hosts' do
    tmp_hosts = 'hosts'
    before do
      content_h = <<'EOF'
#!/bin/bash
echo '{"databases": {"hosts": ["host1.example.com", "host2.example.com"],"vars":{"a": true}}}'
EOF
      create_file(tmp_hosts,content_h)
      File.chmod(0755,tmp_hosts)
      @res = AnsibleSpec.load_targets(tmp_hosts)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 2 group' do
      expect(@res.length).to eq 2
    end

    it 'exist group' do
      expect(@res.key?('databases')).to be_truthy
      expect(@res.key?('hosts_childrens')).to be_truthy
    end

    it 'databases host1.example.com' do
      obj = @res['databases'][0]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'uri' => 'host1.example.com',
                              'port' => 22})
    end

    it 'databases host2.example.com' do
      obj = @res['databases'][1]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'uri' => 'host2.example.com',
                              'port' => 22})
    end

    after do
      File.delete(tmp_hosts)
    end
  end
  context '正常系:DynamicInventory:1 Group, 2 hosts. but no vars' do
    tmp_hosts = 'hosts'
    before do
      content_h = <<'EOF'
#!/bin/bash
echo '{"webservers": [ "host2.example.com", "host3.example.com" ]}'
EOF
      create_file(tmp_hosts,content_h)
      File.chmod(0755,tmp_hosts)
      @res = AnsibleSpec.load_targets(tmp_hosts)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 2 group' do
      expect(@res.length).to eq 2
    end

    it 'exist group' do
      expect(@res.key?('webservers')).to be_truthy
      expect(@res.key?('hosts_childrens')).to be_truthy
    end

    it 'databases host1.example.com' do
      obj = @res['webservers'][0]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'uri' => 'host2.example.com',
                              'port' => 22})
    end

    it 'databases host2.example.com' do
      obj = @res['webservers'][1]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'uri' => 'host3.example.com',
                              'port' => 22})
    end

    after do
      File.delete(tmp_hosts)
    end
  end
end

