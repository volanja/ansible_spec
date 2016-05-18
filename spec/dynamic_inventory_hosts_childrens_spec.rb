# coding: utf-8
require 'ansible_spec'

describe "Dynamic InventoryでChildren関係でhostsを指定しload_targetsの実行" do
  context '正常系:develop-env DynamicInventory:8 Group, 2 hosts' do
    tmp_hosts = 'hosts'
    before do
      content_h = <<'EOF'

#!/bin/bash
#echo '{"database-servers": {"hosts": ["host1.example.com"],"vars":{"a": true}}}'
cat << EOS
{
  "database-servers": {
    "hosts": [
      "10.0.0.4"
    ]
  },
  "application-servers": {
    "hosts": []
  },
  "web-servers": {
    "hosts": [
      "10.0.0.1"
    ]
  },
  "develop-database-servers": {
    "children": [
      "database-servers"
    ]
  },
  "develop-application-servers": {
    "children": [
      "application-servers"
    ]
  },
  "develop-web-servers": {
    "children": [
      "web-servers"
    ]
  },
  "develop": {
    "children": [
      "develop-web-servers",
      "develop-application-servers",
      "develop-database-servers"
    ]
  }
}
EOS
EOF
      create_file(tmp_hosts,content_h)
      File.chmod(0755,tmp_hosts)
      @res = AnsibleSpec.load_targets(tmp_hosts)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 8 group' do
      expect(@res.length).to eq 8
    end

    it 'exist group' do
      expect(@res.key?('hosts_childrens')).to be_truthy
      expect(@res.key?('database-servers')).to be_truthy
      expect(@res.key?('web-servers')).to be_truthy
      expect(@res.key?('application-servers')).to be_truthy
      expect(@res.key?('develop-database-servers')).to be_truthy
      expect(@res.key?('develop-application-servers')).to be_truthy
      expect(@res.key?('develop-web-servers')).to be_truthy
      expect(@res.key?('develop')).to be_truthy
    end

    it 'database-servers 10.0.0.4' do
      obj = @res['database-servers'][0]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'uri' => '10.0.0.4',
                              'port' => 22})
    end

    it 'application-servers empty' do
      obj = @res['application-servers'][0]
      expect(obj).to be_nil
    end

    it 'web-servers 10.0.0.1' do
      obj = @res['web-servers'][0]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'uri' => '10.0.0.1',
                              'port' => 22})
    end

    after do
      File.delete(tmp_hosts)
    end
  end

  context '正常系:staging-env DynamicInventory:8 Group, 3 hosts' do
    tmp_hosts = 'hosts'
    before do
      content_h = <<'EOF'
#!/bin/bash
#echo '{"database-servers": {"hosts": ["host1.example.com", "host2.example.com"],"vars":{"a": true}}}'
cat << EOS
{
  "database-servers": {
    "hosts": [
      "10.1.0.4"
    ]
  },
  "application-servers": {
    "hosts": [
      "10.1.0.2"
    ]
  },
  "web-servers": {
    "hosts": [
      "10.1.0.1"
    ]
  },
  "staging-database-servers": {
    "children": [
      "database-servers"
    ]
  },
  "staging-application-servers": {
    "children": [
      "application-servers"
    ]
  },
  "staging-web-servers": {
    "children": [
      "web-servers"
    ]
  },
  "staging": {
    "children": [
      "staging-web-servers",
      "staging-application-servers",
      "staging-database-servers"
    ]
  }
}
EOS
EOF
      create_file(tmp_hosts,content_h)
      File.chmod(0755,tmp_hosts)
      @res = AnsibleSpec.load_targets(tmp_hosts)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 8 group' do
      expect(@res.length).to eq 8
    end

    it 'exist group' do
      expect(@res.key?('hosts_childrens')).to be_truthy
      expect(@res.key?('database-servers')).to be_truthy
      expect(@res.key?('web-servers')).to be_truthy
      expect(@res.key?('application-servers')).to be_truthy
      expect(@res.key?('staging-database-servers')).to be_truthy
      expect(@res.key?('staging-application-servers')).to be_truthy
      expect(@res.key?('staging-web-servers')).to be_truthy
      expect(@res.key?('staging')).to be_truthy
    end

    it 'database-servers 10.1.0.4' do
      obj = @res['database-servers'][0]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'uri' => '10.1.0.4',
                              'port' => 22})
    end

    it 'application-servers 10.1.0.1' do
      obj = @res['application-servers'][0]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'uri' => '10.1.0.2',
                              'port' => 22})
    end


    it 'web-servers 10.1.0.1' do
      obj = @res['web-servers'][0]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'uri' => '10.1.0.1',
                              'port' => 22})
    end

    after do
      File.delete(tmp_hosts)
    end
  end
  context '正常系:production-env DynamicInventory:8 Group, 4 hosts. but no vars' do
    tmp_hosts = 'hosts'
    before do
      content_h = <<'EOF'
#!/bin/bash
#echo '{"web-servers": [ "host2.example.com", "host3.example.com" ]}'
cat << EOS
{
  "database-servers": {
    "hosts": [
      "10.2.0.4"
    ]
  },
  "application-servers": {
    "hosts": [
      "10.2.0.2",
      "10.2.0.3"
    ]
  },
  "web-servers": {
    "hosts": [
      "10.2.0.1"
    ]
  },
  "production-database-servers": {
    "children": [
      "database-servers"
    ]
  },
  "production-application-servers": {
    "children": [
      "application-servers"
    ]
  },
  "production-web-servers": {
    "children": [
      "web-servers"
    ]
  },
  "production": {
    "children": [
      "production-web-servers",
      "production-application-servers",
      "production-database-servers"
    ]
  }
}
EOS
EOF
      create_file(tmp_hosts,content_h)
      File.chmod(0755,tmp_hosts)
      @res = AnsibleSpec.load_targets(tmp_hosts)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 8 group' do
      expect(@res.length).to eq 8
    end

    it 'exist group' do
      expect(@res.key?('hosts_childrens')).to be_truthy
      expect(@res.key?('database-servers')).to be_truthy
      expect(@res.key?('web-servers')).to be_truthy
      expect(@res.key?('application-servers')).to be_truthy
      expect(@res.key?('production-database-servers')).to be_truthy
      expect(@res.key?('production-application-servers')).to be_truthy
      expect(@res.key?('production-web-servers')).to be_truthy
      expect(@res.key?('production')).to be_truthy
    end

    it 'database-servers 10.2.0.4' do
      obj = @res['database-servers'][0]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'uri' => '10.2.0.4',
                              'port' => 22})
    end

    it 'application-servers 10.2.0.2' do
      obj = @res['application-servers'][0]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'uri' => '10.2.0.2',
                              'port' => 22})
    end

    it 'aplication-servers 10.2.0.3' do
      obj = @res['application-servers'][1]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'uri' => '10.2.0.3',
                              'port' => 22})
    end

    it 'web-servers 10.2.0.1' do
      obj = @res['web-servers'][0]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'uri' => '10.2.0.1',
                              'port' => 22})
    end

    after do
      File.delete(tmp_hosts)
    end
  end
end

