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

describe "load_ansible_cfg" do
  context 'with ANSIBLE_CFG set' do
    tmp_cfg = 'tmp_ansible.cfg'
    saved_env = nil

    before do
      content = <<'EOF'
[ansible_spec1]
roles_path = roles_path1:roles_path2
EOF
      create_file(tmp_cfg,content)
      saved_env = ENV['ANSIBLE_CFG']
      ENV['ANSIBLE_CFG'] = tmp_cfg
      @res = AnsibleSpec::AnsibleCfg.load_ansible_cfg()
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'res has section' do
      expect(@res).to include('ansible_spec1')
    end

    it 'section has roles_path' do
      expect(@res['ansible_spec1']).to include('roles_path')
    end

    it 'roles_path is set' do
      expect(@res['ansible_spec1']['roles_path']).to eq('roles_path1:roles_path2')
    end

    after do
      File.delete(tmp_cfg)
      ENV['ANSIBLE_CFG'] = saved_env
    end
  end
end

describe "AnsibleCfg" do
  context 'with ANSIBLE_CFG set' do
    tmp_cfg = 'tmp_ansible.cfg'
    saved_env = nil

    before do
      content = <<'EOF'
[ansible_spec1]
roles_path = roles_path1:roles_path2
EOF
      create_file(tmp_cfg,content)
      saved_env = ENV['ANSIBLE_CFG']
      ENV['ANSIBLE_CFG'] = tmp_cfg
      @cfg = AnsibleSpec::AnsibleCfg.new
    end

    it 'elem handles unknown sections' do
      expect(@cfg.get('doesnot', 'exist')).to be_nil
    end

    it 'elem handles unknown keys' do
      expect(@cfg.get('ansible_spec1', 'doesnot_exist')).to be_nil
    end

    it 'elem handles known eys ' do
      expect(@cfg.get('ansible_spec1', 'roles_path')).to be_truthy
    end

    it 'cfg has a roles path' do
       expect(@cfg.roles_path).to be_truthy
     end

    after do
      File.delete(tmp_cfg)
      ENV['ANSIBLE_CFG'] = saved_env
    end
  end
end
