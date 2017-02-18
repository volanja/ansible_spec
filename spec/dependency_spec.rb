# coding: utf-8
require 'ansible_spec'


describe "load_dependencies" do
  tmp_hosts = 'hosts'
  tmp_ansiblespec = '.ansiblespec'
  tmp_playbook = 'site.yml'
  tmp_webapp_meta = 'roles/webapp/meta/main.yml'
  tmp_dep1_meta = 'roles/dep1/meta/main.yml'

  spec_content = <<'EOF'
---
-
playbook: site.yml
inventory: hosts
EOF

  hosts_content = <<'EOF'
[normal]
192.168.0.1
192.168.0.2
192.168.0.3
EOF

  playbook_content = <<'EOF'
- name: Ansible-Sample-TDD
hosts: normal
user: root
roles:
  - webapp
EOF

  webapp_meta_content = <<'EOF'
---
dependencies:
- { role: dep1 }
- dep2
EOF

  dep1_meta_content = <<'EOF'
---
dependencies:
- { role: dep3 }
EOF

  before do
    create_file(tmp_hosts, hosts_content)
    create_file(tmp_ansiblespec, spec_content)
    create_file(tmp_playbook, playbook_content)
    create_file(tmp_webapp_meta, webapp_meta_content)
    create_file(tmp_dep1_meta, dep1_meta_content)
    @deps = AnsibleSpec.load_dependencies("webapp")
  end

  it 'should correctly resolve nested dependencies' do
    expect(@deps).to eq ["dep1", "dep2", "dep3"]
  end

  after do
    File.delete(tmp_hosts)
    File.delete(tmp_ansiblespec)
    File.delete(tmp_playbook)
    File.delete(tmp_webapp_meta)
    File.delete(tmp_dep1_meta)
    FileUtils.rm_r(tmp_webapp_meta.split("/")[0])
  end
end

describe "load_dependencies (nil dependencies)" do
  tmp_webapp_meta = 'roles/webapp/meta/main.yml'

  webapp_meta_content = <<'EOF'
---
dependencies:
EOF

  before do
    create_file(tmp_webapp_meta, webapp_meta_content)
    @deps = AnsibleSpec.load_dependencies("webapp")
  end

  it 'should correctly resolve nested dependencies' do
    expect(@deps).to eq []
  end

  after do
    File.delete(tmp_webapp_meta)
    FileUtils.rm_r(tmp_webapp_meta.split("/")[0])
  end
end

describe "load_dependencies from alternative dir" do
  tmp_webapp_meta = 'more_roles/webapp/meta/main.yml'

  webapp_meta_content = <<'EOF'
---
dependencies:
 - foo
EOF

  before do
    create_file(tmp_webapp_meta, webapp_meta_content)
    @deps = AnsibleSpec.load_dependencies("webapp", "more_roles")
  end

  it 'should correctly resolve deps in additional role dirs' do
    expect(@deps).to eq ["foo"]
  end

  after do
    File.delete(tmp_webapp_meta)
    FileUtils.rm_r(tmp_webapp_meta.split("/")[0])
  end
end
