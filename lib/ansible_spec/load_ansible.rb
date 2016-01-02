require 'hostlist_expression'
require 'oj'
require 'open3'

module AnsibleSpec
  # param: inventory file of Ansible
  # return: Hash {"group" => ["192.168.0.1","192.168.0.2"]}
  # return: Hash {"group" => [{"name" => "192.168.0.1","uri" => "192.168.0.1", "port" => 22},...]}
  def self.load_targets(file)
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
    groups.keys.each{|k|
      unless (k =~ search).nil?
        # get group parent & merge parent
        groups.merge!(get_parent(groups,search,k))
        # delete group children
        if groups.has_key?("#{k}") && groups.has_key?("#{k.gsub(search,'')}")
          groups.delete("#{k}")
        end
      end
    }
    return groups
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

    if dyn_inv.key?('_meta')
      # assume we have an ec2.py created dynamic inventory
      res = dyn_inv.tap{ |h| h.delete("_meta") }
    else
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
    end
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
        host['port'] = value.to_i if key == "ansible_ssh_port"
        host['private_key'] = value if key == "ansible_ssh_private_key_file"
        host['user'] = value if key == "ansible_ssh_user"
        host['uri'] = value if key == "ansible_ssh_host"
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
  def self.load_dependencies(role)
    role_queue = [role]
    deps = []
    until role_queue.empty?
      role = role_queue.pop()
      path = File.join("./", "roles", role, "meta", "main.yml")

      if File.exist?(path)
        new_deps = YAML.load_file(path).fetch("dependencies", []).map { |h|
          h["role"]
        }
        role_queue.concat(new_deps)
        deps.concat(new_deps)
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
      puts 'Error: No data in site.yml'
      exit
    end
    properties = Array.new
    playbook.each do |site|
      if site.has_key?("include")
        properties.push YAML.load_file(site["include"])[0]
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
      fail "Please insert name on playbook"
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
    array.each do |site|
      return site.has_key?("name") ? true : false
    end
  end

  # return: json
  # {"name"=>"Ansible-Sample-TDD", "hosts"=>["192.168.0.103"], "user"=>"root", "roles"=>["nginx", "mariadb"]}
  def self.get_properties()
    playbook, inventoryfile = load_ansiblespec

    #load inventry file
    # inventory fileとplaybookのhostsをマッピングする。
    hosts = load_targets(inventoryfile)
    properties = load_playbook(playbook)
    properties.each do |var|
      if var["hosts"].to_s == "all"
        var["hosts"] = hosts.values.flatten
      elsif hosts.has_key?("#{var["hosts"]}")
        var["hosts"] = hosts["#{var["hosts"]}"]
      else
        puts "no hosts matched for #{var["hosts"]}"
      end
    end
    return properties
  end
end
