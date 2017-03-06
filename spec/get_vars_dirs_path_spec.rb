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

describe "Run get_vars_dirs_path" do
  context 'Normal system (environment variable VARS_DIRS_PATH not specified and vars_dirs_path not specified in .ansiblespec)' do
    require 'yaml'
    expected_default_vars_dirs_path = ''

    before do
      @vars_dirs_path = AnsibleSpec.get_vars_dirs_path()
    end

    it "vars_dirs_path is '#{expected_default_vars_dirs_path}'" do
      expect(@vars_dirs_path).to eq expected_default_vars_dirs_path
    end
  end

  context 'Normal system (environment variable VARS_DIRS_PATH specified as current directory and vars_dirs_path not specified in .ansiblespec)' do
    require 'yaml'
    tmp_vars_dirs_path = ''

    before do
      ENV['VARS_DIRS_PATH'] = tmp_vars_dirs_path
      @vars_dirs_path = AnsibleSpec.get_vars_dirs_path()
    end

    it "vars_dirs_path is #{tmp_vars_dirs_path}" do
      expect(@vars_dirs_path).to eq tmp_vars_dirs_path
    end

    after do
      ENV.delete('VARS_DIRS_PATH')
    end
  end

  context 'Normal system (environment variable VARS_DIRS_PATH specified relative to playbook base directory and vars_dirs_path not specified in .ansiblespec)' do
    require 'yaml'
    tmp_vars_dirs_path = 'inventories/staging'

    before do
      ENV['VARS_DIRS_PATH'] = tmp_vars_dirs_path
      @vars_dirs_path = AnsibleSpec.get_vars_dirs_path()
    end

    it "vars_dirs_path is #{tmp_vars_dirs_path}" do
      expect(@vars_dirs_path).to eq tmp_vars_dirs_path
    end

    after do
      ENV.delete('VARS_DIRS_PATH')
    end
  end

  context 'Normal system (environment variable VARS_DIRS_PATH specified as absolute path and vars_dirs_path not specified in .ansiblespec)' do
    require 'yaml'
    tmp_vars_dirs_path = '/etc/ansible/inventories/staging'

    before do
      ENV['VARS_DIRS_PATH'] = tmp_vars_dirs_path
      @vars_dirs_path = AnsibleSpec.get_vars_dirs_path()
    end

    it "vars_dirs_path is #{tmp_vars_dirs_path}" do
      expect(@vars_dirs_path).to eq tmp_vars_dirs_path
    end

    after do
      ENV.delete('VARS_DIRS_PATH')
    end
  end

  context 'Normal line (vars_dirs_path specified relative to playbook base directory in .ansiblespec and environment variable VARS_DIRS_PATH not specified)' do
    require 'yaml'
    tmp_ansiblespec = '.ansiblespec'
    tmp_vars_dirs_path = 'inventories/staging'

    before do

      content = <<'EOF'
---
-
  vars_dirs_path: 'inventories/staging'
EOF
      create_file(tmp_ansiblespec,content)
      @vars_dirs_path = AnsibleSpec.get_vars_dirs_path()
    end

    it "vars_dirs_path is #{tmp_vars_dirs_path}" do
      expect(@vars_dirs_path).to eq tmp_vars_dirs_path
    end

    after do
      File.delete(tmp_ansiblespec)
    end
  end

  context 'Normal line (vars_dirs_path specified as absolute path in .ansiblespec and environment variable VARS_DIRS_PATH not specified)' do
    require 'yaml'
    tmp_ansiblespec = '.ansiblespec'
    tmp_vars_dirs_path = '/etc/ansible/inventories/staging'

    before do

      content = <<'EOF'
---
-
  vars_dirs_path: '/etc/ansible/inventories/staging'
EOF
      create_file(tmp_ansiblespec,content)
      @vars_dirs_path = AnsibleSpec.get_vars_dirs_path()
    end

    it "vars_dirs_path is #{tmp_vars_dirs_path}" do
      expect(@vars_dirs_path).to eq tmp_vars_dirs_path
    end

    after do
      File.delete(tmp_ansiblespec)
    end
  end

  context 'Normal line (ENV VAR higher precedence check: vars_dirs_path specified in .ansiblespec and environment variable VARS_DIRS_PATH specified)' do
    require 'yaml'
    tmp_ansiblespec = '.ansiblespec'
    tmp_vars_dirs_path = 'inventories/staging'

    before do
      ENV['VARS_DIRS_PATH'] = tmp_vars_dirs_path
      content = <<'EOF'
---
-
  vars_dirs_path: 'inventories/development'
EOF
      create_file(tmp_ansiblespec,content)
      @vars_dirs_path = AnsibleSpec.get_vars_dirs_path()
    end

    it "vars_dirs_path is #{tmp_vars_dirs_path}" do
      expect(@vars_dirs_path).to eq tmp_vars_dirs_path
    end

    after do
      File.delete(tmp_ansiblespec)
    end
  end
end
