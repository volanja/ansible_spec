# coding: utf-8
require 'fileutils'
require 'ansible_spec'
require 'pp'

describe "Dynamic Inventoryによるchildrenの依存関係を参照し、get_variablesの実行" do
  context 'Correct operation : develop groups by web-serers hosts childrens' do
    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/group_vars_hosts_childrens_env_dev/')
      @res = AnsibleSpec.get_variables("10.0.0.1", 0, "web-servers")
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 7 pair in Hash' do
      expect(@res.length).to eq 7
    end

    it 'exist each pair' do
      expect(@res).to include( {"all_variable"=>"all!!"},
                               {"logs_conf_file"=>"web_logs.conf"},
                               {"nginx_conf_file"=>"develop_nginx.conf"},
                               {"foo"=>"foofoo-develop"},
                               {"bar"=>["bar1-develop", "bar2-develop", "bar3-develop"]},
                               {"env_name"=>"develop"},
                               {"my_common_libs_version"=>"1.2"}
                             )
    end

    after do
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : develop groups by application-servers hosts childrens ' do
    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/group_vars_hosts_childrens_env_dev/')
      @res_1st = AnsibleSpec.get_variables("10.0.0.2", 0, "application-servers")
      @res_2nd = AnsibleSpec.get_variables("10.0.0.3", 0, "application-servers")
    end

    it 'res is hash' do
      expect(@res_1st.instance_of?(Hash)).to be_truthy
      expect(@res_2nd.instance_of?(Hash)).to be_truthy
    end

    it 'exist 7 pair in Hash' do
      expect(@res_1st.length).to eq 7
      expect(@res_2nd.length).to eq 7
    end

    it 'exist each pair' do
      expect(@res_1st).to include( {"all_variable"=>"all!!"},
                               {"logs_conf_file"=>"application_logs.conf"},
	    					   {"java_version"=>"1.8.0_92"},
                               {"foo"=>"foofoo-develop"},
                               {"bar"=>["bar1-develop", "bar2-develop", "bar3-develop"]},
                               {"env_name"=>"develop"},
                               {"my_common_libs_version"=>"1.2"}
                             )
      expect(@res_2nd).to include( {"all_variable"=>"all!!"},
                               {"logs_conf_file"=>"application_logs.conf"},
	    					   {"java_version"=>"1.8.0_92"},
                               {"foo"=>"foofoo-develop"},
                               {"bar"=>["bar1-develop", "bar2-develop", "bar3-develop"]},
                               {"env_name"=>"develop"},
                               {"my_common_libs_version"=>"1.2"}
                             )
    end

    after do
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : develop groups by database-servers hosts childrens ' do
    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/group_vars_hosts_childrens_env_dev/')
      @res = AnsibleSpec.get_variables("10.0.0.4", 0, "database-servers")
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 8 pair in Hash' do
      expect(@res.length).to eq 8
    end

    it 'exist each pair' do
      expect(@res).to include( {"all_variable"=>"all!!"},
                               {"bar"=>["bar1-develop", "bar2-develop", "bar3-develop"]},
                               {"env_name"=>"develop"},
                               {"foo"=>"foofoo-develop"},
                               {"logs_conf_file"=>"database_logs.conf"},
                               {"my_common_libs_version"=>"1.2"},
                               {"mysql_version"=>"5.7.12"},
                               {"mysql_dependencies_libs"=>["foo-v2","bar-v2"]}
                             )
    end

    after do
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : staging groups by web-serers hosts childrens' do
    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/group_vars_hosts_childrens_env_stg/')
      @res = AnsibleSpec.get_variables("10.0.0.1", 0, "web-servers")
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 7 pair in Hash' do
      expect(@res.length).to eq 7
    end

    it 'exist each pair' do
      expect(@res).to include( {"all_variable"=>"all!!"},
                               {"logs_conf_file"=>"web_logs.conf"},
                               {"nginx_conf_file"=>"staging_nginx.conf"},
                               {"foo"=>"foofoo-staging"},
                               {"bar"=>["bar1-staging", "bar2-staging", "bar3-staging"]},
                               {"env_name"=>"staging"},
                               {"my_common_libs_version"=>"1.1"}
                             )
    end

    after do
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : staging groups by application-servers hosts childrens ' do
    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/group_vars_hosts_childrens_env_stg/')
      @res_1st = AnsibleSpec.get_variables("10.0.0.2", 0, "application-servers")
      @res_2nd = AnsibleSpec.get_variables("10.0.0.3", 0, "application-servers")
    end

    it 'res is hash' do
      expect(@res_1st.instance_of?(Hash)).to be_truthy
      expect(@res_2nd.instance_of?(Hash)).to be_truthy
    end

    it 'exist 7 pair in Hash' do
      expect(@res_1st.length).to eq 7
      expect(@res_2nd.length).to eq 7
    end

    it 'exist each pair' do
      expect(@res_1st).to include( {"all_variable"=>"all!!"},
                               {"logs_conf_file"=>"application_logs.conf"},
							   {"java_version"=>"1.8.0_66"},
                               {"foo"=>"foofoo-staging"},
                               {"bar"=>["bar1-staging", "bar2-staging", "bar3-staging"]},
                               {"env_name"=>"staging"},
                               {"my_common_libs_version"=>"1.1"}
                             )
      expect(@res_2nd).to include( {"all_variable"=>"all!!"},
                               {"logs_conf_file"=>"application_logs.conf"},
	    					   {"java_version"=>"1.8.0_66"},
                               {"foo"=>"foofoo-staging"},
                               {"bar"=>["bar1-staging", "bar2-staging", "bar3-staging"]},
                               {"env_name"=>"staging"},
                               {"my_common_libs_version"=>"1.1"}
                             )
    end

    after do
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : staging groups by database-servers hosts childrens ' do
    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/group_vars_hosts_childrens_env_stg/')
      @res = AnsibleSpec.get_variables("10.0.0.4", 0, "database-servers")
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 8 pair in Hash' do
      expect(@res.length).to eq 8
    end

    it 'exist each pair' do
      expect(@res).to include( {"all_variable"=>"all!!"},
                               {"bar"=>["bar1-staging", "bar2-staging", "bar3-staging"]},
                               {"env_name"=>"staging"},
                               {"foo"=>"foofoo-staging"},
                               {"logs_conf_file"=>"database_logs.conf"},
                               {"my_common_libs_version"=>"1.1"},
							   {"mysql_version"=>"5.6.30"},
                               {"mysql_dependencies_libs"=>["foo-v1","bar-v1"]}
                             )
    end

    after do
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : production groups by web-serers hosts childrens' do
    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/group_vars_hosts_childrens_env_prd/')
      @res = AnsibleSpec.get_variables("10.0.0.1", 0, "web-servers")
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 7 pair in Hash' do
      expect(@res.length).to eq 7
    end

    it 'exist each pair' do
      expect(@res).to include( {"all_variable"=>"all!!"},
                               {"logs_conf_file"=>"web_logs.conf"},
                               {"nginx_conf_file"=>"production_nginx.conf"},
                               {"foo"=>"foofoo-production"},
                               {"bar"=>["bar1-production", "bar2-production", "bar3-production"]},
                               {"env_name"=>"production"},
                               {"my_common_libs_version"=>"1.0"}
                             )
    end

    after do
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : production groups by application-servers hosts childrens ' do
    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/group_vars_hosts_childrens_env_prd/')
      @res_1st = AnsibleSpec.get_variables("10.0.0.2", 0, "application-servers")
      @res_2nd = AnsibleSpec.get_variables("10.0.0.3", 0, "application-servers")
    end

    it 'res is hash' do
      expect(@res_1st.instance_of?(Hash)).to be_truthy
      expect(@res_2nd.instance_of?(Hash)).to be_truthy
    end

    it 'exist 7 pair in Hash' do
      expect(@res_1st.length).to eq 7
      expect(@res_2nd.length).to eq 7
    end

    it 'exist each pair' do
      expect(@res_1st).to include( {"all_variable"=>"all!!"},
                               {"logs_conf_file"=>"application_logs.conf"},
							   {"java_version"=>"1.8.0_45"},
                               {"foo"=>"foofoo-production"},
                               {"bar"=>["bar1-production", "bar2-production", "bar3-production"]},
                               {"env_name"=>"production"},
                               {"my_common_libs_version"=>"1.0"}
                             )
      expect(@res_2nd).to include( {"all_variable"=>"all!!"},
                               {"logs_conf_file"=>"application_logs.conf"},
	    					   {"java_version"=>"1.8.0_45"},
                               {"foo"=>"foofoo-production"},
                               {"bar"=>["bar1-production", "bar2-production", "bar3-production"]},
                               {"env_name"=>"production"},
                               {"my_common_libs_version"=>"1.0"}
                             )
    end

    after do
      Dir.chdir(@current_dir)
    end
  end

  context 'Correct operation : production groups by database-servers hosts childrens ' do
    before do
      @current_dir = Dir.pwd()
      Dir.chdir('spec/case/get_variable/group_vars_hosts_childrens_env_prd/')
      @res = AnsibleSpec.get_variables("10.0.0.4", 0, "database-servers")
    end

    it 'res is hash' do
      expect(@res.instance_of?(Hash)).to be_truthy
    end

    it 'exist 8 pair in Hash' do
      expect(@res.length).to eq 8
    end

    it 'exist each pair' do
      expect(@res).to include( {"all_variable"=>"all!!"},
                               {"bar"=>["bar1-production", "bar2-production", "bar3-production"]},
                               {"env_name"=>"production"},
                               {"foo"=>"foofoo-production"},
                               {"logs_conf_file"=>"database_logs.conf"},
                               {"my_common_libs_version"=>"1.0"},
							   {"mysql_version"=>"5.6.30"},
                               {"mysql_dependencies_libs"=>["foo-v1","bar-v1"]}
                             )
    end

    after do
      Dir.chdir(@current_dir)
    end
  end

end
