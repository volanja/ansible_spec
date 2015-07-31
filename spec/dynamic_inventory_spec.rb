# coding: utf-8
require 'ansible_spec'

describe "load_targets" do
  context 'DynamicInventory' do
    tmp_hosts = 'hosts'
    before do
      content_h = <<'EOF'
#!/bin/bash
echo '{ "group_a": ["host1.example.com", "host2.example.com"], "group_b": ["192.168.0.30", "10.0.0.10", "some.dns.com"]  }'
EOF
      create_file(tmp_hosts,content_h)
      File.chmod(0755,tmp_hosts)
      @res = AnsibleSpec.load_targets(tmp_hosts)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 1 group' do
      expect(@res.length).to eq 2
    end

    it 'exist group' do
      expect(@res.key?('group_a')).to be_truthy
    end

    it 'databases aaa.com' do
      obj = @res['group_b'][0]
      expect(obj.instance_of?(String)).to be_truthy
      expect(obj).to eq '192.168.0.30'
    end

    it 'databases bbb.com' do
      obj = @res['group_a'][1]
      expect(obj.instance_of?(String)).to be_truthy
      expect(obj).to eq 'host2.example.com'
    end

    after do
      File.delete(tmp_hosts)
    end
  end
end

