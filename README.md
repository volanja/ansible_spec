[![Build Status](https://travis-ci.org/stefanhorning/ansible_spec.svg?branch=master)](https://travis-ci.org/stefanhorning/ansible_spec)

# AnsibleSpec gem

This GEM is an Ansible playbook and inventory parser for [Serverspec](http://serverspec.org/).
It makes it easy to introduce role or playbook specs (testing) into your existing ansible project.

It dynamically creates rake tasks for all plays included.

This is a fork of https://github.com/volanja/ansible_spec with a few additions and improvements.
So all credit goes too volanja for providing this tool.

## Features
- Support Serverspec v2
- Support InventoryParameters
  - ansible_ssh_port
  - ansible_ssh_user
  - ansible_ssh_host
  - ansible_ssh_private_key_file
- Support [hostlist expressions](http://docs.ansible.com/intro_inventory.html#hosts-and-groups)
- Support DynamicInventory

## Gem Installation

Install it as a gem by putting it into your Gemfile:
```ruby
gem ansible_spec, git: 'https://github.com/stefanhorning/ansible_spec.git'
```

## Project setup
To create Rakefile, spec/spec_helper.rb and .ansiblespec (initial setup) run the following from your
ansible projects root:

```sh
$ ansiblespec-init
    create  spec
    create  spec/spec_helper.rb
    create  Rakefile
    create  .ansiblespec
```

## The .ansiblespec config file
If you keep the `.ansiblespec` configfile make sure to set the correct filenames (playbook and inventory) in there.
So if you don't use `site.yml` and `hosts`, you have to change this file before using the serverspec rake tasks.
If `.ansiblespec` not found, the script defaults to `site.yml` as playbook and `hosts` as inventory.

Default content of ansiblespec

```yaml
---
-
  playbook: site.yml
  inventory: hosts
```

## Environment variables
You can use Environment variables with the rake commands to overwrite settings in .ansiblespec or the default fallbacks.

- `PLAYBOOK`  playbook name       (e.g. site.yml)
- `INVENTORY` inventory file name (e.g. hosts)

Example to use specific playbook/inventory for this run:
```sh
PLAYBOOK=test.yml INVENTORY=staging/hosts rake serverspec:Ansible-Sample-TDD
```

**ENV vars have priority over `.ansiblespec`**

## Inventory
Ansible spec uses Ansible inventory format and passes it to serverspec. (Rakefile understands notation of Ansible.)

Inventory file can sue this:
- InventoryParameters
  - ansible_ssh_port
  - ansible_ssh_user
  - ansible_ssh_private_key
  - ansible_ssh_host
- define hosts as expressions. `host-[1:3]` would expand into `host-1`,`host-2`,`host-3`
- Group Children
- [DynamicInventory](http://docs.ansible.com/intro_dynamic_inventory.html)

Example inventory file. Basically normal ansible inventory syntax applies:
```
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

```sh
#!/bin/bash
echo '{"databases": {"hosts": ["host1.example.com", "host2.example.com"],"vars":{"a": true}}}'
```

# Sample
## Directory structure within ansible project
As sample project can be found [here](https://github.com/volanja/ansible-sample-tdd).

Example tree. Specs should be placed inside the ansible roles dir. Search pattern be changed in the Rakefile though.
```
.
├── .ansiblespec                 # Config file for ansible_spec. Read above sections. Created by `ansiblespec-init`
├── README.md
├── hosts                        # Used as Ansible inventory to run tests against if nothing else is configured (see above).
├── site.yml                     # Used as ansible playbook to test if nothing else is configured (see above).
├── nginx.yml                    # Included by site.yml
├── roles
│   └── nginx
│       ├── handlers
│       │   └── main.yml
│       ├── spec
│       │   └── nginx_spec.rb    # Serverspec spec file includes spec_helper will be executed by related rake task (where role is used)
│       ├── tasks
│       │   └── main.yml
│       ├── templates
│       │   └── nginx.repo
│       └── vars
│           └── main.yml
├── Rakefile                     # Rakefile containing the rake setup (generates `rake serverspec` tasks) created by `ansiblespec-init`
└── spec                         # Spec file created by `ansiblespec-init` contains the `spec_helper.rb` to be included in all serverspec spec files placed in the roles
    └── spec_helper.rb
```

## Playbook structure
Playbooks can use `include`

```yaml
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

```sh
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

