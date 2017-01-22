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

describe "get_ssh_config_file" do
  context 'with SSH_CONFIG_FILE set' do
    tmp_cfg = 'tmp_ansible.cfg'
    tmp_ssh_cfg = 'hoge_config'
    tmp_env_ssh_cfg = 'env_config'
    saved_env = nil

    before do
      content = <<'EOF'
[ssh_connection]
ssh_args = -F hoge_config
EOF
      content_ssh = <<'EOF'
EOF
      create_file(tmp_cfg,content)
      create_file(tmp_env_ssh_cfg,content_ssh)
      saved_env = ENV['SSH_CONFIG_FILE']
      ENV['SSH_CONFIG_FILE'] = tmp_env_ssh_cfg
      @res = AnsibleSpec.get_ssh_config_file()
    end

    it 'res is hash' do
      expect(@res.instance_of?(String)).to be_truthy
    end

    it 'res has section' do
      expect(@res).to eq('env_config')
    end

    after do
      File.delete(tmp_cfg)
      File.delete(tmp_env_ssh_cfg)
      ENV['SSH_CONFIG_FILE'] = saved_env
    end
  end

  context 'without SSH_CONFIG_FILE set' do
    tmp_cfg = 'tmp_ansible.cfg'
    tmp_ssh_cfg = 'hoge_config'
    saved_env = nil
    saved_env_ansible = nil

    before do
      content = <<'EOF'
[ssh_connection]
ssh_args = -F hoge_config
EOF
      content_ssh = <<'EOF'
EOF
      create_file(tmp_cfg,content)
      saved_env_ansible = ENV['ANSIBLE_CFG']
      ENV['ANSIBLE_CFG'] = tmp_cfg

      create_file(tmp_ssh_cfg,content_ssh)

      saved_env = ENV['SSH_CONFIG_FILE']
      ENV['SSH_CONFIG_FILE'] = nil
      @res = AnsibleSpec.get_ssh_config_file()
    end

    it 'res is hash' do
      expect(@res.instance_of?(String)).to be_truthy
    end

    it 'res has section' do
      expect(@res).to eq('hoge_config')
    end

    after do
      File.delete(tmp_cfg)
      File.delete(tmp_ssh_cfg)
      ENV['ANSIBLE_CFG'] = saved_env_ansible
      ENV['SSH_CONFIG_FILE'] = saved_env
    end
  end

  context 'not set -F <file> at ANSIBLE_CFG' do
    tmp_cfg = 'tmp_ansible.cfg'
    saved_env = nil
    saved_env_ansible = nil

    before do
      content = <<'EOF'
[ssh_connection]
ssh_args = -o ControlMaster=auto
EOF
      content_ssh = <<'EOF'
EOF
      create_file(tmp_cfg,content)
      saved_env_ansible = ENV['ANSIBLE_CFG']
      ENV['ANSIBLE_CFG'] = tmp_cfg

      saved_env = ENV['SSH_CONFIG_FILE']
      ENV['SSH_CONFIG_FILE'] = nil
      @res = AnsibleSpec.get_ssh_config_file()
    end

    it 'res has section' do
      expect(@res).to eq nil
    end

    after do
      File.delete(tmp_cfg)
      ENV['SSH_CONFIG_FILE'] = saved_env
      ENV['ANSIBLE_CFG'] = saved_env_ansible
    end
  end

  context 'not exist SSH_CONFIG_FILE' do
    tmp_cfg = 'tmp_ansible.cfg'
    saved_env = nil
    saved_env_ansible = nil

    before do
      content = <<'EOF'
[ssh_connection]
ssh_args = -F hoge_config
EOF
      create_file(tmp_cfg,content)
      saved_env = ENV['SSH_CONFIG_FILE']
      ENV['SSH_CONFIG_FILE'] = nil
      saved_env_ansible = ENV['ANSIBLE_CFG']
      ENV['ANSIBLE_CFG'] = tmp_cfg
      @res = AnsibleSpec.get_ssh_config_file()
    end

    it 'res has section' do
      expect(@res).to eq nil
    end

    after do
      File.delete(tmp_cfg)
      ENV['SSH_CONFIG_FILE'] = saved_env
      ENV['ANSIBLE_CFG'] = saved_env_ansible
    end
  end
end

