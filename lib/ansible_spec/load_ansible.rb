# -*- coding: utf-8 -*-
require 'hostlist_expression'
require 'oj'
require 'open3'
require 'yaml'
require 'inifile'
require 'ansible_spec/vendor/hash'

module AnsibleSpec
  # param: inventory file of Ansible
  # param: return_type 'groups' or 'groups_parent_child_relationships'
  # return: Hash {"group" => ["192.168.0.1","192.168.0.2"]}
  # return: Hash {"group" => [{"name" => "192.168.0.1","uri" => "192.168.0.1", "port" => 22},...]}
  # return: Hash {"pg" => ["server", "databases"]}
  def self.load_targets(file, return_type = 'groups')
    if not ['groups', 'groups_parent_child_relationships'].include?(return_type)
      raise ArgumentError, "Variable return_type must be value 'groups' or 'groups_parent_child_relationships'"
    end

    if File.executable?(file)
      return get_dynamic_inventory(file)
    end
    f = File.open(file).read
    groups = Hash.new
    group = ''
    hosts = Hash.new
    hosts.default = Hash.new
    f.each_line{|line|
      line = line.chomp
      # skip
      next if line.start_with?('#') #comment
      next if line.empty? == true   #null

      # get group
      if line.start_with?('[') && line.end_with?(']')
        group = line.gsub('[','').gsub(']','')
        groups["#{group}"] = Array.new
        next
      end

      # get host
      host_name = line.split[0]
      if group.empty? == false
        if groups.has_key?(line)
          groups["#{group}"] << line
          next
        elsif host_name.include?("[") && host_name.include?("]")
          # www[01:50].example.com
          # db-[a:f].example.com
          hostlist_expression(line,":").each{|h|
            host = hosts[h.split[0]]
            groups["#{group}"] << get_inventory_param(h).merge(host)
          }
          next
        else
          # 1つのみ、かつ:を含まない場合
          # 192.168.0.1
          # 192.168.0.1 ansible_ssh_host=127.0.0.1 ...
          host = hosts[host_name]
          groups["#{group}"] << get_inventory_param(line).merge(host)
          next
        end
      else
        if host_name.include?("[") && host_name.include?("]")
          hostlist_expression(line, ":").each{|h|
            hosts[h.split[0]] = get_inventory_param(h)
          }
        else
          hosts[host_name] = get_inventory_param(line)
        end
      end
    }

    # parse children [group:children]
    search = Regexp.new(":children".to_s)
    groups_parent_child_relationships = Hash.new
    groups.keys.each{|k|
      unless (k =~ search).nil?
        # get parent child relationships
        k_parent = k.gsub(search,'')
        groups_parent_child_relationships["#{k_parent}"] = groups["#{k}"]
        # get group parent & merge parent
        groups.merge!(get_parent(groups,search,k))
        # delete group children
        if groups.has_key?("#{k}") && groups.has_key?("#{k.gsub(search,'')}")
          groups.delete("#{k}")
        end
      end
    }

    return_value = groups # default
    if return_type == 'groups'
      return_value = groups
    elsif return_type == 'groups_parent_child_relationships'
      return_value = groups_parent_child_relationships
    end

    return return_value
  end

  # param  hash   {"server"=>["192.168.0.103"], "databases"=>["192.168.0.104"], "pg:children"=>["server", "databases"]}
  # param  search ":children"
  # param  k      "pg:children"
  # return {"server"=>["192.168.0.103"], "databases"=>["192.168.0.104"], "pg"=>["192.168.0.103", "192.168.0.104"]}
  def self.get_parent(hash,search,k)
    k_parent = k.gsub(search,'')
    arry = Array.new
    hash["#{k}"].each{|group|
      arry = arry + hash["#{group}"]
    }
    h = Hash.new
    h["#{k_parent}"] = arry
    return h
  end

  # param filename
  #       {"databases":{"hosts":["aaa.com","bbb.com"],"vars":{"a":true}}}
  #       {"webservers":["aaa.com","bbb.com"]}
  # return: Hash {"databases"=>[{"uri" => "aaa.com", "port" => 22}, {"uri" => "bbb.com", "port" => 22}]}
  def self.get_dynamic_inventory(file)
    if file[0] == "/"
      file_path = file
    else
      file_path = "./#{file}"
    end
    res = Hash.new
    so, se, st = Open3.capture3(file_path)
    dyn_inv = Oj.load(so.to_s)

    res["hosts_childrens"] = dyn_inv.select do |property, value|
      value.instance_of?(Hash) && value.has_key?("children")
    end

    if dyn_inv.key?('_meta')
      # assume we have an ec2.py created dynamic inventory
      dyn_inv = dyn_inv.tap{ |h| h.delete("_meta") }
    end
    dyn_inv.each{|k,v|
      res["#{k.to_s}"] = Array.new unless res.has_key?("#{k.to_s}")
      if v.is_a?(Array)
        # {"webservers":["aaa.com","bbb.com"]}
        v.each {|host|
          res["#{k.to_s}"] << {"uri"=> host, "port"=> 22}
        }
      elsif v.has_key?("hosts") && v['hosts'].is_a?(Array)
        v['hosts'].each {|host|
          res["#{k.to_s}"] << {"uri"=> host, "port"=> 22}
        }
      end
    }
    return res
  end

  # param ansible_ssh_port=22
  # return: hash
  def self.get_inventory_param(line)
    host = Hash.new
    # 初期値
    host['name'] = line
    host['port'] = 22
    if line.include?(":") # 192.168.0.1:22
      host['uri']  = line.split(":")[0]
      host['port'] = line.split(":")[1].to_i
      return host
    end
    # 192.168.0.1 ansible_ssh_port=22
    line.split.each{|v|
      unless v.include?("=")
        host['uri'] = v
      else
        key,value = v.split("=")
        host['port'] = value.to_i if key == "ansible_ssh_port" or key == "ansible_port"
        host['private_key'] = value if key == "ansible_ssh_private_key_file"
        host['user'] = value if key == "ansible_ssh_user" or key == "ansible_user"
        host['uri'] = value if key == "ansible_ssh_host" or key == "ansible_host"
        host['pass'] = value if key == "ansible_ssh_pass"
        host['connection'] = value if key == "ansible_connection"
      end
    }
    return host
  end

  # param: none
  # return: playbook, inventoryfile
  def self.load_ansiblespec()
    f = '.ansiblespec'
    y = nil
    if File.exist?(f)
      y = YAML.load_file(f)
    end
    if ENV["PLAYBOOK"]
      playbook = ENV["PLAYBOOK"]
    elsif y.is_a?(Array) && y[0]['playbook']
      playbook = y[0]['playbook']
    else
      playbook = 'site.yml'
    end
    if ENV["INVENTORY"]
      inventoryfile = ENV["INVENTORY"]
    elsif y.is_a?(Array) && y[0]['inventory']
      inventoryfile = y[0]['inventory']
    else
      inventoryfile = 'hosts'
    end
    if File.exist?(playbook) == false
      puts 'Error: ' + playbook + ' is not Found. create site.yml or ./.ansiblespec  See https://github.com/volanja/ansible_spec'
      exit 1
    elsif File.exist?(inventoryfile) == false
      puts 'Error: ' + inventoryfile + ' is not Found. create hosts or ./.ansiblespec  See https://github.com/volanja/ansible_spec'
      exit 1
    end
    return playbook, inventoryfile
  end

  # param: role
  # return: ["role1", "role2"]
  def self.load_dependencies(role, rolepath='roles')
    role_queue = [role]
    deps = []
    until role_queue.empty?
      role = role_queue.pop()
      path = File.join(rolepath, role, "meta", "main.yml")

      if File.exist?(path)
        dependencies = YAML.load_file(path).fetch("dependencies", [])
        unless dependencies.nil?
          new_deps = dependencies.map { |h|
            h["role"] || h
          }
          role_queue.concat(new_deps)
          deps.concat(new_deps)
        end
      end
    end
    return deps
  end

  # param: playbook
  # return: json
  #         {"name"=>"Ansible-Sample-TDD", "hosts"=>"server", "user"=>"root", "roles"=>["nginx", "mariadb"]}
  def self.load_playbook(f)
    playbook = YAML.load_file(f)

    # e.g. comment-out
    if playbook === false
      puts "Error: No data in #{f}"
      exit
    end
    properties = Array.new
    playbook.each do |site|
      if site.has_key?("include")
          YAML.load_file(site["include"]).each { |site|
            properties.push site
          }
      elsif site.has_key?("import_playbook")
          YAML.load_file(site["import_playbook"]).each { |site|
            properties.push site
          }
      else
        properties.push site
      end
    end
    properties.each do |property|
      property["roles"] = flatten_role(property["roles"])
    end
    if name_exist?(properties)
      return properties
    else
      fail "Please insert name on playbook '#{f}'"
    end
  end

  # flatten roles (Issue 29)
  # param: Array
  #        e.g. ["nginx"]
  #        e.g. [{"role"=>"nginx"}]
  #        e.g. [{"role"=>"nginx", "dir"=>"/opt/b", "port"=>5001}]
  # return: Array
  #         e.g.["nginx"]
  def self.flatten_role(roles)
    ret = Array.new
    if roles
      roles.each do |role|
        if role.is_a?(String)
          ret << role
        elsif role.is_a?(Hash)
          ret << role["role"] if role.has_key?("role")
        end
      end
    end
    return ret
  end


  # Issue 27
  # param: array
  # return: boolean
  #         true: name is exist on playbook
  #         false: name is not exist on playbook
  def self.name_exist?(array)
    array.all? do |site|
      site.has_key?("name")
    end
  end

  # param: none
  # return: hash_behaviour
  def self.get_hash_behaviour()
    f = '.ansiblespec'
    y = nil
    if File.exist?(f)
      y = YAML.load_file(f)
    end
    hash_behaviour = 'replace'
    if ENV["HASH_BEHAVIOUR"]
      hash_behaviour = ENV["HASH_BEHAVIOUR"]
    elsif y.is_a?(Array) && y[0]['hash_behaviour']
      hash_behaviour = y[0]['hash_behaviour']
    end
    if !['replace','merge'].include?(hash_behaviour)
      puts "Error: hash_behaviour '" + hash_behaviour + "' should be 'replace' or 'merge' See https://github.com/volanja/ansible_spec"
      exit 1
    end
    return hash_behaviour
  end

  # param: none
  # return: file path
  def self.get_ssh_config_file()
    ssh_config_file = nil

    cfg = AnsibleSpec::AnsibleCfg.new
    ssh_args = cfg.get('ssh_connection', 'ssh_args')
    if ssh_args
      array = ssh_args.split(" ")
      if array.index("-F") && array[array.index("-F") + 1]
        ssh_config_file = array[array.index("-F") + 1]
      end
    end

    if ENV["SSH_CONFIG_FILE"]
      ssh_config_file = ENV["SSH_CONFIG_FILE"]
    end

    return nil if ssh_config_file.nil?

    if File.exist?(ssh_config_file)
      return ssh_config_file
    else
      return nil
    end
  end

  # param: hash
  # param: variable file
  # param: flag to extention
  #         true:  .yml extension is optional
  #         false: must have .yml extention
  def self.load_vars_file(vars, path, check_no_ext = false)
    vars_file = path
    if check_no_ext && !File.exist?(vars_file)
      vars_file = path+".yml"
    end
    if File.exist?(vars_file)
      if File.directory?(vars_file)
        Dir.glob(File.join(vars_file, '*')).each { |f|
          vars = load_vars_file(vars, f)
	      }
      else
        yaml = YAML.load_file(vars_file)
        vars = merge_variables(vars, yaml)
      end
    end
    return vars
  end

  # param: target hash
  # param: be merged hash
  def self.merge_variables(vars, hash)
    hash_behaviour = get_hash_behaviour()
    if hash.kind_of?(Hash)
      if hash_behaviour=="merge"
        vars.deep_merge!(hash)
      else
        vars.merge!(hash)
      end
    end
    return vars
  end

  # return: json
  # {"name"=>"Ansible-Sample-TDD", "hosts"=>["192.168.0.103"], "user"=>"root", "roles"=>["nginx", "mariadb"]}
  def self.get_properties()
    playbook, inventoryfile = load_ansiblespec

    # load inventory file and playbook hosts mapping
    hosts = load_targets(inventoryfile)
    properties = load_playbook(playbook)
    properties.each do |var|
      var["hosts_childrens"] = hosts["hosts_childrens"]
      var["group"] = var["hosts"]
      if var["hosts"].to_s == "all"
        var["hosts"] = hosts.values.flatten
      elsif hosts.has_key?("#{var["hosts"]}")
        var["hosts"] = hosts["#{var["hosts"]}"]
      elsif var["hosts"].instance_of?(Array)
        tmp_host = var["hosts"]
        var["hosts"] = []
        tmp_host.each do |v|
          if hosts.has_key?("#{v}")
            hosts["#{v}"].map {|target_server| target_server["hosts"] = v}
            var["hosts"].concat hosts["#{v}"]
          end
        end
        if var["hosts"].size == 0
          properties = properties.compact.reject{|e| e["hosts"].length == 0}
          #puts "#{var["name"]} roles no hosts matched for #{var["hosts"]}"
        end
      else
        puts "no hosts matched for #{var["hosts"]}"
        var["hosts"] = []
      end
    end
    return properties
  end

  # param: none
  # return: vars_dirs_path
  def self.get_vars_dirs_path()
    f = '.ansiblespec'
    y = nil
    if File.exist?(f)
      y = YAML.load_file(f)
    end
    if ENV["VARS_DIRS_PATH"]
      vars_dirs_path = ENV["VARS_DIRS_PATH"]
    elsif y.is_a?(Array) && y[0]['vars_dirs_path']
      vars_dirs_path = y[0]['vars_dirs_path']
    else
      vars_dirs_path = ''
    end
    return vars_dirs_path
  end

  def self.find_group_vars_file(hosts_childrens, hosts)
      target_host = hosts_childrens.select { |key, value|
        value["children"].include?(hosts)
      }
      target_host.keys[0]
  end

  # query replace jinja2 templates with target values 
  # param: hash (cf. result self.get_variables)
  # param: number of iterations if found_template
  # return: hash
  def self.resolve_variables(vars, max_level=100)
    vars_yaml = vars.to_yaml
    level = 0
    begin
      found_template = false
      level += 1

      # query replace jinja2 templates in yaml
      # replace in-place (gsub!)
      # use non-greedy regex (.*?)
      vars_yaml.gsub!(/{{.*?}}/) do |template|

        # grab target variable
        # ignore whitespaces (\s*)
        # use non-greedy regex (.*?)
        target = template.gsub(/{{\s*(.*?)\s*}}/, '\1')
        
        # lookup value of target variable
        value = vars[target]
        
        # return lookup value if it exists
        # or leave template alone  
        if value.nil? 
          template
        else 
          found_template = true
          value
        end
      end
    end while found_template and level <= max_level
    return YAML.load(vars_yaml)
  end

  def self.get_variables(host, group_idx, hosts=nil)
    vars = {}
    p = self.get_properties

    # roles default
    p[group_idx]['roles'].each do |role|
      vars = load_vars_file(vars ,"roles/#{role}/defaults/main.yml")
    end

    # get parent directory of group_vars and host_vars directories
    vars_dirs_path = get_vars_dirs_path
    if vars_dirs_path != ''
      vars_dirs_path = "#{vars_dirs_path}/"
    end

    # all group
    vars = load_vars_file(vars ,"#{vars_dirs_path}group_vars/all", true)

    # each group vars
    if p[group_idx].has_key?('group')
      # get groups parent child relationships
      playbook, inventoryfile = load_ansiblespec
      groups_rels = load_targets(inventoryfile, return_type='groups_parent_child_relationships')
      # get parental lineage
      g = p[group_idx]['group']
      groups_stack = Array.new
      groups_stack << g
      groups_rels.keys.each{|k|
        groups_stack << k if (groups_rels[k].include?(g))
      }
      # get vars from parents groups then child group
      groups_parents_then_child = groups_stack.reverse.flatten
      groups_parents_then_child.each{|group|
        vars = load_vars_file(vars ,"#{vars_dirs_path}group_vars/#{group}", true)
      }
    end

    # each host vars
    vars = load_vars_file(vars ,"#{vars_dirs_path}host_vars/#{host}", true)

    # site vars
    if p[group_idx].has_key?('vars')
      vars = merge_variables(vars, p[group_idx]['vars'])
    end

    # roles vars
    p[group_idx]['roles'].each do |role|
      vars = load_vars_file(vars ,"roles/#{role}/vars/main.yml")
    end

    # multiple host and children dependencies group vars
    unless hosts.nil? || p[group_idx]["hosts_childrens"].nil?
      hosts_childrens = p[group_idx]["hosts_childrens"]
      next_find_target = hosts
      while(!next_find_target.nil? && hosts_childrens.size > 0)
        vars = load_vars_file(vars ,"#{vars_dirs_path}group_vars/#{next_find_target}", true)
        group_vars_file = find_group_vars_file(hosts_childrens,next_find_target)
        next_find_target = group_vars_file
        hosts_childrens.delete(group_vars_file)
      end
    end

    return resolve_variables(vars)

  end

  class AnsibleCfg
    def initialize
      @cfg = self.class.load_ansible_cfg
    end

    def roles_path
      rp = (self.get('defaults', 'roles_path') or '').split(':')
      rp << 'roles'  # Roles is always searched
    end

    class << self
      def find_ansible_cfgs()
        files = []
        ["/etc/ansible/ansible.cfg",
         File.expand_path("~/.ansible.cfg"),
         "./ansible.cfg",
         ENV["ANSIBLE_CFG"],
        ].each do |f|
          files << f if f and File.exists? f
        end
      end

      def load_ansible_cfg()
        cfg = IniFile.new
        self.find_ansible_cfgs.each do |file|
          cfg = cfg.merge(IniFile.new :filename => file)
        end
        cfg.to_h
      end
    end

    def get(section, key)
      s = @cfg[section]
      if s
        return s[key]
      else
        return nil
      end
    end
  end
end
