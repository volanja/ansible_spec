# coding: utf-8
require 'ansible_spec'

describe "load_targetsの実行" do
  context '正常系:複数グループ:変数' do
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

    it 'exist 1 group' do
      expect(@res.length).to eq 1
    end

    it 'exist group' do
      expect(@res.key?('databases')).to be_truthy
    end

    it 'databases aaa.com' do
      obj = @res['databases'][0]
      expect(obj.instance_of?(String)).to be_truthy
      expect(obj).to eq 'host1.example.com'
    end

    it 'databases bbb.com' do
      obj = @res['databases'][1]
      expect(obj.instance_of?(String)).to be_truthy
      expect(obj).to eq 'host2.example.com'
    end

    after do
      File.delete(tmp_hosts)
    end
  end
end

