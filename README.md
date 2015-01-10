# AnsibleSpec
[![Gem Version](https://badge.fury.io/rb/ansible_spec.svg)](http://badge.fury.io/rb/ansible_spec)
[![Build Status](https://travis-ci.org/volanja/ansible_spec.svg?branch=master)](https://travis-ci.org/volanja/ansible_spec)  

**v0.1 is Work In Progress**

This gem is Ansible Config Parser for Serverspec.  
Serverspec RakeTask use Ansible Config(InventoryFile and Playbook).  
Support Run Multi Role and Multi Host of Ansible.  

This gem created template file Until v0.0.1.4,  
But it was modularized on v0.1. Because module is easy to unit-test and Rakefile is simple.  

If you want old release that can create template, see [v0.0.1.4](https://github.com/volanja/ansible_spec/tree/v0.0.1.4).  
and use `gem install ansible_spec -v 0.0.1.4`  
But I can't support old release.  

##[WIP] New feature at v0.1

- [x] Support ServerSpec v2
- [x] Simplification Rakefile and Modularization. Because of Improvement of testability.
- [x] Support InventoryParameters  
(ansible_ssh_host, ansible_ssh_port, ansible_ssh_user, ansible_ssh_private_key_file)
- [x] Support [hostlist expressions](http://docs.ansible.com/intro_inventory.html#hosts-and-groups)
- [x] Support DynamicInventory

And so on...

## Installation

install it yourself as:

    $ gem install ansible_spec

## Usage

### Create file Serverspec

```
$ ansiblespec-init 
    create  spec
    create  spec/spec_helper.rb
    create  Rakefile
    create  .ansiblespec
```

### Change .ansiblespec(v0.0.1.3)
If `.ansiblespec` is exist, use variables(playbook and inventory).  
So, If you don't use `site.yml` and `hosts`, you change this file.  
If `.ansiblespec` not found, use `site.yml` as playbook and `hosts` as inventory.  

```.ansiblespec
--- 
- 
  playbook: site.yml
  inventory: hosts
```

### Create Ansible Directory

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

### Serverspec with Ansible
Serverspec use this file.  (Rakefile understand Notation of Ansible.)  

* hosts  
hosts can use [group_name]  

```hosts
[server]
192.168.0.103
192.168.0.104

```

* site.yml  
site.yml can use ```include```  

```site.yml
- name: Ansible-Sample-TDD
  hosts: server
  user: root
  roles:
    - nginx
```

## Run Test
```
$ rake -T
rake serverspec:Ansible-Sample-TDD  # Run serverspec for Ansible-Sample-TDD

$ rake serverspec:Ansible-Sample-TDD
Run serverspec for Ansible-Sample-TDD to 192.168.0.103
/Users/Adr/.rvm/rubies/ruby-1.9.3-p194/bin/ruby -S rspec roles/mariadb/spec/mariadb_spec.rb roles/nginx/spec/nginx_spec.rb
...........

Finished in 0.34306 seconds
11 examples, 0 failures
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
