# AnsibleSpec
[![Gem Version](https://badge.fury.io/rb/ansible_spec.svg)](http://badge.fury.io/rb/ansible_spec)
[![Build Status](https://travis-ci.org/volanja/ansible_spec.svg?branch=master)](https://travis-ci.org/volanja/ansible_spec)  

This gem is Ansible Config Parser for Serverspec.  
Serverspec RakeTask uses Ansible Config(InventoryFile and Playbook).  
Support Run Multi Role and Multi Host of Ansible.  

# feature

- Support Serverspec v2
- Support InventoryParameters  
  - ansible_ssh_port
  - ansible_ssh_user
  - ansible_ssh_host
  - ansible_ssh_private_key_file
- Support [hostlist expressions](http://docs.ansible.com/intro_inventory.html#hosts-and-groups)
- Support DynamicInventory

# Installation

install it yourself as:

```
$ gem install ansible_spec
```

# Usage
## Create Rakafile & spec/spec_helper.rb

```
$ ansiblespec-init 
    create  spec
    create  spec/spec_helper.rb
    create  Rakefile
    create  .ansiblespec
```

## [Option] .ansiblespec
If `.ansiblespec` is exist, use variables(playbook and inventory).  
So, If you don't use `site.yml` and `hosts`, you change this file.  
If `.ansiblespec` not found, use `site.yml` as playbook and `hosts` as inventory.  

```.ansiblespec
--- 
- 
  playbook: site.yml
  inventory: hosts
```


## Inventory
Serverspec use Ansible Inventory.  (Rakefile understand Notation of Ansible.)  

Inventory file can sue this:
- InventoryParameters
  - ansible_ssh_port
  - ansible_ssh_user
  - ansible_ssh_private_key
  - ansible_ssh_host
- define hosts as expressions. `host-[1:3]` would expand into `host-1`,`host-2`,`host-3`
- Group Children
- [DynamicInventory](http://docs.ansible.com/intro_dynamic_inventory.html)

### Sample

```hosts
[server]
# skip line(comment)
# normal
192.168.0.1
# use port 5309
192.168.0.3:5309
# use port 22
192.168.0.2 ansible_ssh_port=22
# use Private-key ~/.ssh/id_rsa
192.168.0.4 ansible_ssh_private_key_file=~/.ssh/id_rsa
# use user `git`
192.168.0.5 ansible_ssh_user=git
# use port 5555 & host 192.168.1.50
jumper ansible_ssh_port=5555 ansible_ssh_host=192.168.1.50

[web]
# www1.example.com to www99.example.com
www[1:99].example.com
# www01.example.com to www99.example.com
www[01:99].example.com

[databases]
# db-a.example.com to db-z.example.com
db-[a:z].example.com
# db-A.example.com to db-Z.example.com
db-[A:Z].example.com

# Multi Group. use server & databases
[parent:children]
server
databases
```

## DynamicInventory(need execute permission)

```
#!/bin/bash
echo '{"databases": {"hosts": ["host1.example.com", "host2.example.com"],"vars":{"a": true}}}'
```


# Sample
## Directory
sample is [here](https://github.com/volanja/ansible-sample-tdd)

```
.
├── .ansiblespec                 #Create file (use Serverspec). read above section.
├── README.md
├── hosts                        #use Ansible and Serverspec if .ansiblespec is not exist.
├── site.yml                     #use Ansible and Serverspec if .ansiblespec is not exist. 
├── nginx.yml                    #(comment-out) incluted by site.yml
├── roles
│   └── nginx
│       ├── handlers
│       │   └── main.yml
│       ├── spec                 #use Serverspec
│       │   └── nginx_spec.rb
│       ├── tasks
│       │   └── main.yml
│       ├── templates
│       │   └── nginx.repo
│       └── vars
│           └── main.yml
├── Rakefile                     #Create file (use Serverspec)
└── spec                         #Create file (use Serverspec)
    └── spec_helper.rb
```

## Playbook
playbook can use `include`  

```site.yml
- name: Ansible-Sample-TDD
  hosts: server
  user: root
  roles:
    - nginx
- name: Ansible-Sample-TDD2
  hosts: parent
  user: root
  roles:
    - nginx
```

## Run Test

```
$ rake -T
rake serverspec:Ansible-Sample-TDD   # Run serverspec for Ansible-Sample-TDD
rake serverspec:Ansible-Sample-TDD2  # Run serverspec for Ansible-Sample-TDD2

$ rake serverspec:Ansible-Sample-TDD
Run serverspec for Ansible-Sample-TDD to 192.168.0.103
/Users/Adr/.rvm/rubies/ruby-1.9.3-p194/bin/ruby -S rspec roles/mariadb/spec/mariadb_spec.rb roles/nginx/spec/nginx_spec.rb
...........

Finished in 0.34306 seconds
11 examples, 0 failures
```

# Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
