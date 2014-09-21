# AnsibleSpec
[![Gem Version](https://badge.fury.io/rb/ansible_spec.svg)](http://badge.fury.io/rb/ansible_spec)

This is Severspec template for Run test Multi Role and Multi Host with Ansible  
Create template (Rakefile and spec/spec_hepler.rb)  
Serverspec template use Ansible InventoryFile and site.yml

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
