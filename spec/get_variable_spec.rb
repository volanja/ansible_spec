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

    it 'exist three pairs in Hash' do
      expect(@res.length).to eq 3
    end

    it 'exists each pair' do
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

    it 'exist five pairs in Hash' do
      expect(@res.length).to eq 5
    end

    it 'exists each pair' do
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

    it 'exist five pairs in Hash' do
      expect(@res.length).to eq 5
    end

    it 'exists each pair' do
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

    it 'exist three pairs in Hash' do
      expect(@res.length).to eq 3
    end

    it 'exists each pair' do
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

    it 'exist three pairs in Hash' do
      expect(@res.length).to eq 3
    end

    it 'exists each pair' do
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

    it 'exist two pairs in Hash' do
      expect(@res.length).to eq 2
    end

    it 'exists each pair' do
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

    it 'exist five pairs in Hash' do
      expect(@res.length).to eq 5
    end

    it 'exists each pair' do
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

    it 'exist five pairs in Hash' do
      expect(@res.length).to eq 5
    end

    it 'exists each pair' do
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
  
  context 'Correct operation : deep_merge' do
    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/deep_merge')
      @res = AnsibleSpec.get_variables('192.168.1.1', 0)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exists one pair in Hash' do
      expect(@res.length).to eq 1
    end
   
    it 'exists the pair' do
      expect(@res).to include({'merge_var' => {
                                'keep'=>'role',
                                'override'=>'site',
                                'add'=>'site'
                              }},
                             )
    end

    after do
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : group vars for group1 hosts ' do
    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/group_each_vars_parent_child/')
      ENV["PLAYBOOK"] = 'site1.yml'
      ENV["INVENTORY"] = 'hosts'
      ENV["VARS_DIRS_PATH"] = ''
      @res = AnsibleSpec.get_variables("192.168.1.1", 0, "group1")
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 6 pair in Hash' do
      expect(@res.length).to eq 6
    end

    it 'exist each pair' do
      expect(@res).to include( {"role_var"=>"group1"},
                               {"site_var"=>"group1"},
                               {"host_var"=>"group1"},
                               {"group_var"=>"group1"},
                               {"group_var_parent"=>"parentgroup"},
                               {"group_all_var"=>"group all"}
                             )
    end

    after do
      ENV.delete('PLAYBOOK')
      ENV.delete('INVENTORY')
      ENV.delete('VARS_DIRS_PATH')
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : group vars for group2 hosts ' do
    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/group_each_vars_parent_child/')
      ENV["PLAYBOOK"] = 'site2.yml'
      ENV["INVENTORY"] = 'hosts'
      ENV["VARS_DIRS_PATH"] = ''
      @res = AnsibleSpec.get_variables("192.168.1.2", 0, "group2")
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 6 pair in Hash' do
      expect(@res.length).to eq 6
    end

    it 'exist each pair' do
      expect(@res).to include( {"role_var"=>"group2"},
                               {"site_var"=>"group2"},
                               {"host_var"=>"group2"},
                               {"group_var"=>"group2"},
                               {"group_var_parent"=>"parentgroup"},
                               {"group_all_var"=>"group all"}
                             )
    end

    after do
      ENV.delete('PLAYBOOK')
      ENV.delete('INVENTORY')
      ENV.delete('VARS_DIRS_PATH')
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : group vars for parentgroup hosts ' do
    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/group_each_vars_parent_child/')
      ENV["PLAYBOOK"] = 'site3.yml'
      ENV["INVENTORY"] = 'hosts'
      ENV["VARS_DIRS_PATH"] = ''
      @res = AnsibleSpec.get_variables("192.168.1.1", 0, "parentgroup")
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 6 pair in Hash' do
      expect(@res.length).to eq 6
    end

    it 'exist each pair' do
      expect(@res).to include( {"role_var"=>"parentgroup"},
                               {"site_var"=>"parentgroup"},
                               {"host_var"=>"parentgroup"},
                               {"group_var"=>"parentgroup"},
                               {"group_var_parent"=>"parentgroup"},
                               {"group_all_var"=>"group all"}
                             )
    end

    after do
      ENV.delete('PLAYBOOK')
      ENV.delete('INVENTORY')
      ENV.delete('VARS_DIRS_PATH')
      Dir.chdir(@current_dir)
    end
  end

end

describe "get_hash_behaviourの実行" do
  context 'Correct operation : should get replace' do
    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_hash_behaviour/basic')
    end

    it 'should get replace' do
      res = AnsibleSpec.get_hash_behaviour()
      expect(res).to eq 'replace'
    end

    after do
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : merge in ENV["HASH_BEHAVIOUR"]' do
    before do
      ENV["HASH_BEHAVIOUR"] = 'merge'
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_hash_behaviour/basic')
    end

    it 'should get merge' do
      res = AnsibleSpec.get_hash_behaviour()
      expect(res).to eq 'merge'
    end

    after do
      ENV.delete('HASH_BEHAVIOUR')
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : resolve variables' do
    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/resolve_variables/')
      @res = AnsibleSpec.get_variables('192.168.1.1', 0)
    end
  
    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end
  
    it 'exist fourteen pairs in Hash' do
      expect(@res.length).to eq 14
    end
  
    it 'exist all pairs' do
      expect(@res).to include({'var_nested_one_1' => 'val_nested_one'})
      expect(@res).to include({'var_nested_one_2' => 'val_nested_one'})
      expect(@res).to include({'var_nested_two_1' => 'val_nested_two'})
      expect(@res).to include({'var_nested_two_2' => 'val_nested_two'})
      expect(@res).to include({'var_nested_two_3' => 'val_nested_two'})
      expect(@res).to include({'var_nested_hash_1' => 'val_hash'})
      expect(@res).to include({'var_nested_hash_2' => {'key' => 'val_hash'}})
      expect(@res).to include({'var_nested_array_1' => 'val_array'})
      expect(@res).to include({'var_nested_array_2' => ['val_array']})
      expect(@res).to include({'var_nested_array_hash_1' => 'val_array_hash'})
      expect(@res).to include({'var_nested_array_hash_2' => [{'key' => 'val_array_hash'}]})
      expect(@res).to include({'var_nested_whitespace_1' => 'val_nested_whitespace'})
      expect(@res).to include({'var_nested_whitespace_2' => 'val_nested_whitespace'})
      expect(@res).to include({'var_missingtarget_2' => '{{ var_missingtarget_1 }}'})
    end
  
    after do
      Dir.chdir(@current_dir)
    end
  end  

  context 'Correct operation : mistake word in ENV["HASH_BEHAVIOUR"]' do
    before do
      ENV["HASH_BEHAVIOUR"] = 'mistake_word'
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_hash_behaviour/basic')
    end

    it 'exitする' do
      expect{ AnsibleSpec.get_hash_behaviour }.to raise_error(SystemExit)
    end

    after do
      ENV.delete('HASH_BEHAVIOUR')
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : with .ansiblespec' do
    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_hash_behaviour/with_ansiblespec')
    end

    it 'should get merge' do
      res = AnsibleSpec.get_hash_behaviour()
      expect(res).to eq 'merge'
    end

    after do
      ENV.delete('HASH_BEHAVIOUR')
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : overwrite ENV["HASH_BEHAVIOUR"]' do
    before do
      ENV["HASH_BEHAVIOUR"] = 'replace'
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_hash_behaviour/with_ansiblespec')
    end

    it 'should get merge' do
      res = AnsibleSpec.get_hash_behaviour()
      expect(res).to eq 'replace'
    end

    after do
      ENV.delete('HASH_BEHAVIOUR')
      Dir.chdir(@current_dir)
    end
  end
end

describe 'merge_variablesの実行' do
  context 'Correct operation : deep_merge (merge)' do
    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/deep_merge')
      h1 = {'merge_var' => {'keep'=>'h1','override'=>'h1','add'=>'h1'}}
      h2 = {'merge_var' => {'override'=>'h2','add'=>'h2'}}
      @res = AnsibleSpec.merge_variables(h1, h2)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 1 pair in Hash' do
      expect(@res.length).to eq 1
    end

    it 'should h1 + h2' do
      expect(@res).to include({'merge_var' => {
                                'keep'=>'h1',
                                'override'=>'h2',
                                'add'=>'h2'
                              }},
                             )
    end

    after do
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : deep_merge (replace)' do
    before do
      ENV["HASH_BEHAVIOUR"] = 'replace'
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/deep_merge')
      h1 = {'merge_var' => {'keep'=>'h1','override'=>'h1','add'=>'h1'}}
      h2 = {'merge_var' => {'override'=>'h2','add'=>'h2'}}
      @res = AnsibleSpec.merge_variables(h1, h2)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exists one pair in Hash' do
      expect(@res.length).to eq 1
    end

    it 'should replace from h1 to h2' do
      expect(@res).to include({'merge_var' => {
                                'override'=>'h2',
                                'add'=>'h2'
                              }},
                             )
    end

    after do
      ENV.delete('HASH_BEHAVIOUR')
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

    it 'exist one pair in Hash' do
      expect(@res.length).to eq 1
    end

    it 'exists the pair' do
      expect(@res).to include({'role_var' => 'without .yml extension'})
    end

    after do
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : deep merge' do
  # https://github.com/volanja/ansible_spec/pull/66
  # group_vars/xxx priority is higher than group_vars/xxx.yml.
    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/load_vars_file/group_all_deep_merge/')
      vars = Hash.new
      file = 'group_vars/all'
      @res = AnsibleSpec.load_vars_file(vars, file, true)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exists one pair in Hash' do
      expect(@res.length).to eq 1
    end

    it 'exists the pair' do
      expect(@res).to include({'role_var' => 'without .yml extension'})
    end

    after do
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : vars in directory' do
    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/load_vars_file/vars_dir/')
      vars = Hash.new
      file = 'group_vars/all'
      @res = AnsibleSpec.load_vars_file(vars, file)
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist two pairs in Hash' do
      expect(@res.length).to eq 2
    end

    it 'exists each pair' do
      expect(@res).to include({'var1' => 'val1'})
      expect(@res).to include({'var2' => 'val2'})
    end

    after do
      Dir.chdir(@current_dir)
    end
  end

end
