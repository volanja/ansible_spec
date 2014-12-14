module AnsibleSpec
  # param: inventory file of Ansible
  # return: Hash {"active_group_name" => ["192.168.0.1","192.168.0.2"]}
  def self.load_targets(file)
    hosts = File.open(file).read
    active_group = Hash.new
    active_group_name = ''
    hosts.each_line{|line|
      line = line.chomp
      next if line.start_with?('#')
      if line.start_with?('[') && line.end_with?(']')
        active_group_name = line.gsub('[','').gsub(']','')
        active_group["#{active_group_name}"] = Array.new
      elsif active_group_name.empty? == false
        next if line.empty? == true
        active_group["#{active_group_name}"] << line
      end
    }
    return active_group
  end

  # param: none
  # return: playbook, inventoryfile
  def self.load_ansiblespec()
    f = '.ansiblespec'
    if File.exist?(f)
      y = YAML.load_file(f)
      playbook = y[0]['playbook']
      inventoryfile = y[0]['inventory']
    else
      playbook = 'site.yml'
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
end
