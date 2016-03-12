# coding: utf-8
require 'fileutils'
require 'ansible_spec'

describe "get_variablesの実行" do
  context 'Correct operation : roles default' do
    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/roles_default/')
      @res = AnsibleSpec.get_variables('192.168.1.1', 0)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 3 pair in Hash' do
      expect(@res.length).to eq 3
    end

    it 'exist each pair' do
      expect(@res).to include({'role_var' => 'role_var in roles default'},
                              {'site_var' => 'site_var in roles default'},
                              {'host_var'=>'host_var in roles default'},
                             )
    end

    after do
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : all groups' do
    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/group_all/')
      @res = AnsibleSpec.get_variables('192.168.1.1', 0)
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
                              {'host_var'=>'group all'},
                              {'group_var'=>'group all'},
                              {'group_all_var'=>'group all'}
                             )
    end

    after do
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : each group vars' do
    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/group_each_vars/')
      @res = AnsibleSpec.get_variables('192.168.1.1', 0)
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
                              {'host_var'=>'group1'},
                              {'group_var'=>'group1'},
                              {'group_all_var'=>'group all'}
                             )
    end

    after do
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : host_vars' do
    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/host_vars/')
      @res = AnsibleSpec.get_variables('192.168.1.1', 0)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 3 pair in Hash' do
      expect(@res.length).to eq 3
    end

    it 'exist each pair' do
      expect(@res).to include({'role_var' => 'host role_var'},  # in host_var/192.168.1.1.yml
                              {'site_var' => 'host site_var'},  # in host_var/192.168.1.1.yml
                              {'host_var'=>'host 192.168.1.1'}, # in host_var/192.168.1.1.yml
                             )
    end

    after do
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : host_vars' do
    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/host_vars/')
      @res = AnsibleSpec.get_variables('192.168.1.2', 1)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 3 pair in Hash' do
      expect(@res.length).to eq 3
    end

    it 'exist each pair' do
      expect(@res).to include({'role_var' => 'host role_var'},  # in host_var/192.168.1.2.yml
                              {'site_var' => 'host site_var'},  # in host_var/192.168.1.2.yml
                              {'host_var'=>'host 192.168.1.2'}, # in host_var/192.168.1.2.yml
                             )
    end

    after do
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : playbook only' do
    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/playbook_only/')
      @res = AnsibleSpec.get_variables('192.168.1.1', 0)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 2 pair in Hash' do
      expect(@res.length).to eq 2
    end

    it 'exist each pair' do
      expect(@res).to include({'role_var' => 'site'},
                              {'site_var' => 'site'})
    end

    after do
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : playbook & group_var & host_var' do
    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/group_host_playbook/')
      @res = AnsibleSpec.get_variables('192.168.1.1', 0)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 5 pair in Hash' do
      expect(@res.length).to eq 5
    end

    it 'exist each pair' do
      expect(@res).to include({'role_var' => 'site'}, # site.yml
                              {'site_var' => 'site'}, # site.yml
                              {'host_var'=>'host 192.168.1.1'}, # in host_var/192.168.1.1.yml
                              {'group_var'=>'group1'}, # in group_var/all.yml
                              {'group_all_var'=>'group all'} # in group_var/all.yml
                              )
    end

    after do
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : playbook & group_var & host_var & variable in role' do
    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/group_host_playbook_role/')
      @res = AnsibleSpec.get_variables('192.168.1.1', 0)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 5 pair in Hash' do
      expect(@res.length).to eq 5
    end

    it 'exist each pair' do
      expect(@res).to include({'role_var' => 'role'}, # in roles/test/vars/main.yml
                              {'site_var' => 'site'}, # site.yml
                              {'host_var'=>'host 192.168.1.1'}, # in host_var/192.168.1.1.yml
                              {'group_var'=>'group1'}, # in group_var/all.yml
                              {'group_all_var'=>'group all'} # in group_var/all.yml
                              )
    end

    after do
      Dir.chdir(@current_dir)
    end
  end
end

describe "load_vars_fileの実行" do
  context 'Correct operation : without .yml extension' do
  # https://github.com/volanja/ansible_spec/pull/66
  # group_vars/xxx priority is higher than group_vars/xxx.yml.
    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/load_vars_file/group_all/')
      vars = Hash.new
      file = 'group_vars/all'
      @res = AnsibleSpec.load_vars_file(vars, file)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 1 pair in Hash' do
      expect(@res.length).to eq 1
    end

    it 'exist each pair' do
      expect(@res).to include({'role_var' => 'without .yml extension'})
    end

    after do
      Dir.chdir(@current_dir)
    end
  end
end
