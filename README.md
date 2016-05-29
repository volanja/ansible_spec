# AnsibleSpec

[![Gem Version](https://badge.fury.io/rb/ansible_spec.svg)](http://badge.fury.io/rb/ansible_spec)
[![Build Status](https://travis-ci.org/volanja/ansible_spec.svg?branch=master)](https://travis-ci.org/volanja/ansible_spec)

This is a Ruby gem that implements an Ansible Config Parser for Serverspec.
It creates a Rake task that can run tests, using Ansible inventory files
and playbooks. You can test multiple roles and multiple hosts.

# Features

- Supports [Serverspec](http://serverspec.org/) v2
- Supports special host variables
  - `ansible_ssh_port`
  - `ansible_ssh_user`
  - `ansible_ssh_host`
  - `ansible_ssh_private_key_file`
- Supports [host patterns/ranges](http://docs.ansible.com/intro_inventory.html#hosts-and-groups) -- e.g.: `www[01:50].example.com`
- Supports Ansible [dynamic inventory sources](http://docs.ansible.com/ansible/intro_dynamic_inventory.html)

# Installation

```
$ gem install ansible_spec
```

# Usage

## Create `Rakefile` & `spec/spec_helper.rb`

```
$ ansiblespec-init
    create  spec
    create  spec/spec_helper.rb
    create  Rakefile
    create  .ansiblespec
    create  .rspec
```

## [Optional] `.ansiblespec`

By default, `site.yml` will be used as the playbook and `hosts` as the
inventory file. You can either follow these conventions or you can
customize the playbook and inventory using an `.ansiblespec` file.

```.ansiblespec
---
-
  playbook: site.yml
  inventory: hosts
  hash_behaviour: merge
```

## [Optional] Environment variables

You can use environment variables with the `rake` command. They are listed below.

- `PLAYBOOK`       -- playbook name                                (e.g. `site.yml`)
- `INVENTORY`      -- inventory file name                          (e.g. `hosts`)
- `HASH_BEHAVIOUR` -- hash behaviour when duplicate hash variables (e.g. `merge`)

Environment variables take precedence over the `.ansiblespec` file.

Example:

```
$ PLAYBOOK=site.yml INVENTORY=hosts rake serverspec:Ansible-Sample-TDD
or
$ PLAYBOOK=site.yml rake serverspec:Ansible-Sample-TDD
or
$ INVENTORY=hosts rake serverspec:Ansible-Sample-TDD
or
$ HASH_BEHAVIOUR=merge rake serverspec:Ansible-Sample-TDD
```

HASH_BEHAVIOUR is same as Ansible's hash behaviour parameter. By default, 'replace'.
See http://docs.ansible.com/ansible/intro_configuration.html#hash-behaviour.

## Inventory

Inventory files can:

- use standard ansible parameters
  - `ansible_ssh_port`
  - `ansible_ssh_user`
  - `ansible_ssh_private_key`
  - `ansible_ssh_host`
- define hosts as expressions. `host-[1:3]` would expand into `host-1`,`host-2`,`host-3`
- Group Children
- Use [dynamic inventory sources](http://docs.ansible.com/intro_dynamic_inventory.html)

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

## Dynamic Inventory Sources

(Note: These files need to have execute permission)

```
#!/bin/bash
echo '{"databases": {"hosts": ["host1.example.com", "host2.example.com"],"vars":{"a": true}}}'
```

## Variables

Ansible variables supported by following condition.

* Playbook's variables are supported. If same variable is defined in different places,
  priority follows [Ansible order](http://docs.ansible.com/ansible/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable).
* Variables defined main.yml in role's tasks are not supported.
* Inventry variables are not supported.
* Facts are not supported.

### Sample

Support variables are in site.yml, group_vars, host_vars, roles.

```
├── site.yml
├── group_vars
│   ├── all.yml
│   ├── dbserver.yml
│   └── webserver.yml
├── host_vars
│   ├── 192.168.1.1.yml
│   └── 192.168.1.2.yml
└── roles
    ├── apaches
    │   └── vars
    │       └── main.yml
    └── mariadb
        └── vars
            └── main.yml

```

#### Define variable(site.yml)


```
- name: Ansible-Variable-Sample
  hosts: webserver.yml
  user: root
  vars:
    - www_port: 8080
  roles:
    - nginx
```

#### Spec file(roles/nginx/spec/nginx_spec.rb)

```
describe port(property['www_port']) do
  it { should be_listening }
end
```

# Sample
## Directory
sample is [here](https://github.com/volanja/ansible-sample-tdd)

```
.
├── .ansiblespec                 # Create file (use Serverspec). read above section.
├── .rspec                       # Create file (use Serverspec). read RSpec Doc.
├── README.md
├── hosts                        # use Ansible and Serverspec if .ansiblespec is not exist.
├── site.yml                     # use Ansible and Serverspec if .ansiblespec is not exist.
├── nginx.yml                    # (comment-out) incluted by site.yml
├── roles
│   └── nginx
│       ├── handlers
│       │   └── main.yml
│       ├── spec                 # use Serverspec
│       │   └── nginx_spec.rb
│       ├── tasks
│       │   └── main.yml
│       ├── templates
│       │   └── nginx.repo
│       └── vars
│           └── main.yml
├── Rakefile                     # Create file (use Serverspec)
└── spec                         # Create file (use Serverspec)
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

To set up a development environment:

```
$ bundle install
```

To run the tests:

```
$ bundle exec rspec
```

To contribute your change, create a GitHub pull request as follows:

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request at https://github.com/volanja/ansible_spec
