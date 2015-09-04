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
    res = Hash.new
    group = ''
    f.each_line{|line|
      line = line.chomp
      # skip
      next if line.start_with?('#') #comment
      next if line.empty? == true   #null

      # get group
      if line.start_with?('[') && line.end_with?(']')
        group = line.gsub('[','').gsub(']','')
        res["#{group}"] = Array.new
        next
      end

      #get host
      if group.empty? == false
        host = Hash.new
        # 1つのみ、かつ:を含まない場合
        if line.split.count == 1 && !line.include?(":")
          # 192.168.0.1
          res["#{group}"] << line
          next
        elsif line.split.count == 1 && line.include?("[") && line.include?("]")
          # www[01:50].example.com
          # db-[a:f].example.com
          hostlist_expression(line,":").each{|h|
            res["#{group}"] << h
          }
          next
        else
          res["#{group}"] << get_inventory_param(line)
          next
        end
      end
    }

    # parse children [group:children]
    search = Regexp.new(":children".to_s)
    res.keys.each{|k|
      unless (k =~ search).nil?
        # get group parent & merge parent
        res.merge!(get_parent(res,search,k))
        # delete group children
        if res.has_key?("#{k}") && res.has_key?("#{k.gsub(search,'')}")
          res.delete("#{k}")
        end
      end
    }
    return res
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
  # Made comapatible with ec2.py dynamic inventory script from ansible
  # http://docs.ansible.com/ansible/intro_dynamic_inventory.html#example-aws-ec2-external-inventory-script
  def self.get_dynamic_inventory(file)
    so, se, st = Open3.capture3("./#{file}")
    raise "Error while executing dynamic inventory script: #{se}" if so.empty?
    Oj.load(so.to_s)
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
        host['connection'] = value if key == "ansible_connection"
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
    file = '.ansiblespec'
    if File.exist?(file)
      config = YAML.load_file(file)
      if config
        playbook = config[0]['playbook']
        inventoryfile = config[0]['inventory']
      else
        raise "Config file #{file} was empty/no valid yml file. please provide playbook and inventory params."
      end
    else
      playbook = 'site.yml'
      inventoryfile = 'hosts'
    end
    # Overwrite values if env variables are given
    playbook = ENV["PLAYBOOK"] if ENV["PLAYBOOK"]
    inventoryfile = ENV["INVENTORY"] if ENV["INVENTORY"]

    if File.exist?(playbook) == false
      raise "Error: #{playbook} is not Found. create site.yml or ./.ansiblespec  See https://github.com/volanja/ansible_spec"
    elsif File.exist?(inventoryfile) == false
      raise "Error:  #{inventoryfile} is not Found. create hosts or ./.ansiblespec  See https://github.com/volanja/ansible_spec"
    end
    [playbook, inventoryfile]
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
        properties.push YAML.load_file(site["include"].split.first)[0]
      else
        properties.push site
      end
    end
    properties.each do |property|
      property["roles"] = flatten_role(property["roles"]) if property["roles"]
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
  #        e.g. [{"roles"=>"nginx"}]
  #        e.g. [{"role"=>"nginx", "dir"=>"/opt/b", "port"=>5001}]
  # return: Array
  #         e.g.["nginx"]
  def self.flatten_role(roles)
    ret = Array.new
    roles.each do |role|
      if role.is_a?(String)
        ret << role
      elsif role.is_a?(Hash)
        ret << role["role"] if role.has_key?("role")
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
        puts "No matching inventory found for play '#{var['name']}'"
      end
    end
    return properties
  end
end
