# coding: utf-8
require 'ansible_spec'

describe "Static Inventory load targets" do
  context 'Dev and prod, 9 groups, 3 hosts' do
    tmp_hosts = 'hosts'
    before do
      content_h = <<'EOF'
[dev-database-servers]
10.0.0.4

[prod-database-servers]
10.1.0.4

[dev-application-servers]

[dev-web-servers]
hosts 10.0.0.1

[database-servers:children]
dev-database-servers
prd-database-servers

[application-servers]
dev-application-servers

[web-servers]
dev-web-servers

[dev:children]
dev-web-servers
dev-application-servers
dev-database-servers

[prod:children]
prod-database-servers
EOF
      create_file(tmp_hosts,content_h)
      @res = AnsibleSpec.load_targets(tmp_hosts)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 8 group' do
      expect(@res.length).to eq 9
    end

    it 'exist group' do
      expect(@res.key?('dev-database-servers')).to be_truthy
      expect(@res.key?('prod-database-servers')).to be_truthy
      expect(@res.key?('dev-application-servers')).to be_truthy
      expect(@res.key?('dev-web-servers')).to be_truthy
      expect(@res.key?('database-servers')).to be_truthy
      expect(@res.key?('application-servers')).to be_truthy
      expect(@res.key?('web-servers')).to be_truthy
      expect(@res.key?('dev')).to be_truthy
      expect(@res.key?('prod')).to be_truthy
    end

    it 'database-servers 10.0.0.4' do
      obj = @res['database-servers'][0]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'uri' => '10.0.0.4',
                              'port' => 22})
    end

    it 'dev-application-servers empty' do
      obj = @res['dev-application-servers'][0]
      expect(obj).to be_nil
    end

    it 'prod 10.1.0.4' do
      obj = @res['prod'][0]
      expect(obj.instance_of?(Hash)).to be_truthy
      expect(obj).to include({'uri' => '10.1.0.4',
                              'port' => 22})
    end

    after do
      File.delete(tmp_hosts)
    end
  end
end

