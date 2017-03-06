# coding: utf-8
require 'fileutils'
require 'ansible_spec'

describe "Run get_variables" do
  context 'Correct operation : env VARS_DIRS_PATH=inventories/staging - all groups' do
    require 'yaml'
    tmp_playbook = 'site.yml'
    tmp_inventory_file = 'inventories/staging/hosts'
    tmp_vars_dirs_path = 'inventories/staging'

    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/inventories_env_group_all/')
      ENV["PLAYBOOK"] = tmp_playbook
      ENV["INVENTORY"] = tmp_inventory_file
      ENV["VARS_DIRS_PATH"] = tmp_vars_dirs_path
      @res = AnsibleSpec.get_variables('192.168.2.1', 0)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 5 pair in Hash' do
      expect(@res.length).to eq 5
    end

    it 'exist each pair' do
      expect(@res).to include({'role_var' => 'group all'},
                              {'site_var' => 'group all'},
                              {'host_var' => 'group all'},
                              {'group_var' => 'group all'},
                              {'group_all_var' => 'group all'}
                             )
    end

    after do
      ENV.delete('PLAYBOOK')
      ENV.delete('INVENTORY')
      ENV.delete('VARS_DIRS_PATH')
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : env VARS_DIRS_PATH=inventories/staging - each group vars' do
    require 'yaml'
    tmp_playbook = 'site.yml'
    tmp_inventory_file = 'inventories/staging/hosts'
    tmp_vars_dirs_path = 'inventories/staging'

    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/inventories_env_group_each_vars/')
      ENV["PLAYBOOK"] = tmp_playbook
      ENV["INVENTORY"] = tmp_inventory_file
      ENV["VARS_DIRS_PATH"] = tmp_vars_dirs_path
      @res = AnsibleSpec.get_variables('192.168.2.1', 0)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 5 pair in Hash' do
      expect(@res.length).to eq 5
    end

    it 'exist each pair' do
      expect(@res).to include({'role_var' => 'group1'},
                              {'site_var' => 'group1'},
                              {'host_var' => 'group1'},
                              {'group_var' => 'group1'},
                              {'group_all_var' => 'group all'}
                             )
    end

    after do
      ENV.delete('PLAYBOOK')
      ENV.delete('INVENTORY')
      ENV.delete('VARS_DIRS_PATH')
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : env VARS_DIRS_PATH=inventories/staging - host_vars' do
    require 'yaml'
    tmp_playbook = 'site.yml'
    tmp_inventory_file = 'inventories/staging/hosts'
    tmp_vars_dirs_path = 'inventories/staging'

    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/inventories_env_host_vars/')
      ENV["PLAYBOOK"] = tmp_playbook
      ENV["INVENTORY"] = tmp_inventory_file
      ENV["VARS_DIRS_PATH"] = tmp_vars_dirs_path
      @res = AnsibleSpec.get_variables('192.168.2.1', 0)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 3 pair in Hash' do
      expect(@res.length).to eq 3
    end

    it 'exist each pair' do
      expect(@res).to include({'role_var' => 'host role_var'},   # in host_var/192.168.2.1.yml
                              {'site_var' => 'host site_var'},   # in host_var/192.168.2.1.yml
                              {'host_var' => 'host 192.168.2.1'} # in host_var/192.168.2.1.yml
                             )
    end

    after do
      ENV.delete('PLAYBOOK')
      ENV.delete('INVENTORY')
      ENV.delete('VARS_DIRS_PATH')
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : env VARS_DIRS_PATH=inventories/staging - host_vars' do
    require 'yaml'
    tmp_playbook = 'site.yml'
    tmp_inventory_file = 'inventories/staging/hosts'
    tmp_vars_dirs_path = 'inventories/staging'

    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/inventories_env_host_vars/')
      ENV["PLAYBOOK"] = tmp_playbook
      ENV["INVENTORY"] = tmp_inventory_file
      ENV["VARS_DIRS_PATH"] = tmp_vars_dirs_path
      @res = AnsibleSpec.get_variables('192.168.2.2', 1)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 3 pair in Hash' do
      expect(@res.length).to eq 3
    end

    it 'exist each pair' do
      expect(@res).to include({'role_var' => 'host role_var'},   # in host_var/192.168.2.2.yml
                              {'site_var' => 'host site_var'},   # in host_var/192.168.2.2.yml
                              {'host_var' => 'host 192.168.2.2'} # in host_var/192.168.2.2.yml
                             )
    end

    after do
      ENV.delete('PLAYBOOK')
      ENV.delete('INVENTORY')
      ENV.delete('VARS_DIRS_PATH')
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : .ansiblespec "vars_dirs_path: inventories/staging" - all groups' do
    require 'yaml'
    tmp_ansiblespec = '.ansiblespec'

    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/inventories_env_group_all/')
      content = <<'EOF'
---
-
  playbook: 'site.yml'
  inventory: 'inventories/staging/hosts'
  vars_dirs_path: 'inventories/staging'
EOF
      create_file(tmp_ansiblespec,content)
      @res = AnsibleSpec.get_variables('192.168.2.1', 0)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 5 pair in Hash' do
      expect(@res.length).to eq 5
    end

    it 'exist each pair' do
      expect(@res).to include({'role_var' => 'group all'},
                              {'site_var' => 'group all'},
                              {'host_var' => 'group all'},
                              {'group_var' => 'group all'},
                              {'group_all_var' => 'group all'}
                             )
    end

    after do
      File.delete(tmp_ansiblespec)
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : .ansiblespec "vars_dirs_path: inventories/staging" - each group vars' do
    require 'yaml'
    tmp_ansiblespec = '.ansiblespec'

    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/inventories_env_group_each_vars/')
      content = <<'EOF'
---
-
  playbook: 'site.yml'
  inventory: 'inventories/staging/hosts'
  vars_dirs_path: 'inventories/staging'
EOF
      create_file(tmp_ansiblespec,content)
      @res = AnsibleSpec.get_variables('192.168.2.1', 0)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 5 pair in Hash' do
      expect(@res.length).to eq 5
    end

    it 'exist each pair' do
      expect(@res).to include({'role_var' => 'group1'},
                              {'site_var' => 'group1'},
                              {'host_var' => 'group1'},
                              {'group_var' => 'group1'},
                              {'group_all_var' => 'group all'}
                             )
    end

    after do
      File.delete(tmp_ansiblespec)
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : .ansiblespec "vars_dirs_path: inventories/staging" - host_vars' do
    require 'yaml'
    tmp_ansiblespec = '.ansiblespec'

    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/inventories_env_host_vars/')
      content = <<'EOF'
---
-
  playbook: 'site.yml'
  inventory: 'inventories/staging/hosts'
  vars_dirs_path: 'inventories/staging'
EOF
      create_file(tmp_ansiblespec,content)
      @res = AnsibleSpec.get_variables('192.168.2.1', 0)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 3 pair in Hash' do
      expect(@res.length).to eq 3
    end

    it 'exist each pair' do
      expect(@res).to include({'role_var' => 'host role_var'},   # in host_var/192.168.2.1.yml
                              {'site_var' => 'host site_var'},   # in host_var/192.168.2.1.yml
                              {'host_var' => 'host 192.168.2.1'} # in host_var/192.168.2.1.yml
                             )
    end

    after do
      File.delete(tmp_ansiblespec)
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : .ansiblespec "vars_dirs_path: inventories/staging" - host_vars' do
    require 'yaml'
    tmp_ansiblespec = '.ansiblespec'

    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/inventories_env_host_vars/')
      content = <<'EOF'
---
-
  playbook: 'site.yml'
  inventory: 'inventories/staging/hosts'
  vars_dirs_path: 'inventories/staging'
EOF
      create_file(tmp_ansiblespec,content)
      @res = AnsibleSpec.get_variables('192.168.2.2', 1)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 3 pair in Hash' do
      expect(@res.length).to eq 3
    end

    it 'exist each pair' do
      expect(@res).to include({'role_var' => 'host role_var'},   # in host_var/192.168.2.2.yml
                              {'site_var' => 'host site_var'},   # in host_var/192.168.2.2.yml
                              {'host_var' => 'host 192.168.2.2'} # in host_var/192.168.2.2.yml
                             )
    end

    after do
      File.delete(tmp_ansiblespec)
      Dir.chdir(@current_dir)
    end
  end
end
