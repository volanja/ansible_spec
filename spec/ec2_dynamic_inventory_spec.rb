# coding: utf-8
require 'ansible_spec'

describe "load_targets_ec2" do
  context 'EC2_DynamicInventory' do
    tmp_hosts = 'hosts'
    before do
      content_h = <<'EOF'
#!/bin/bash
echo '{ "_meta": { "hostvars": { "some_key1": { "ec2_something_something": false }, "some_key2": { "ec2_something_something": true }}}, "tag_some_other_key1": [ "host-1", "host-2" ], "some_other_key2": [ "host-1" ]}'
EOF
      create_file(tmp_hosts,content_h)
      File.chmod(0755,tmp_hosts)
      @res = AnsibleSpec.load_targets(tmp_hosts)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'contains 3 groups' do
      expect(@res.length).to eq 3
    end

    it 'contains key tag_some_other_key1' do
      expect(@res.key?('tag_some_other_key1')).to be_truthy
    end

    it 'contains key some_other_key2' do
      expect(@res.key?('some_other_key2')).to be_truthy
    end

    it 'tag_some_other_key1 contains host-1 and host-2' do
      obj = @res['tag_some_other_key1'][0]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'uri' => 'host-1',
                              'port' => 22})
      obj = @res['tag_some_other_key1'][1]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'uri' => 'host-2',
                              'port' => 22})
    end

    it 'some_other_key2 contains host-1' do
      obj = @res['some_other_key2'][0]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'uri' => 'host-1',
                              'port' => 22})
    end

    after do
      File.delete(tmp_hosts)
    end
  end
  context 'EC2_DynamicInventory' do
    tmp_hosts = 'hosts'
    before do
      content_h = <<'EOF'
#!/bin/bash
echo '{ "_meta" : {"hostvars": {"54.1.2.3": {"ec2_ip_address": "54.1.2.3","ec2_key_name": "my-secret-key", "ec2_launch_time": "2016-01-06T03:59:56.000Z", "ec2_tag_Name": "sample-app", "ec2_tag_Stack": "sample-app"}}},"tag_Name_sample_app": ["54.1.2.3"]}'
EOF
      create_file(tmp_hosts,content_h)
      File.chmod(0755,tmp_hosts)
      @res = AnsibleSpec.load_targets(tmp_hosts)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'contains 2 groups' do
      expect(@res.length).to eq 2
    end

    it 'contains key tag_Name_sample_app' do
      expect(@res.key?('tag_Name_sample_app')).to be_truthy
    end

    it 'tag_Name_sample_app contains hash' do
      obj = @res['tag_Name_sample_app'][0]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'uri' => '54.1.2.3',
                              'port' => 22})
    end

    after do
      File.delete(tmp_hosts)
    end
  end
end

