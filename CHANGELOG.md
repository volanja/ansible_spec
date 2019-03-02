# v0.2.25
- Merge [#118 Incorporate group parent child relationships into variable assignment hierarchy](https://github.com/volanja/ansible_spec/pull/118) by [rbramwell](https://github.com/rbramwell)

# v0.2.24
- Merge [#117 Feature resolve variables](https://github.com/volanja/ansible_spec/pull/117) by [RebelCodeBase](https://github.com/RebelCodeBase)

# v0.2.23
- Merge [#115 Support import_playbook](https://github.com/volanja/ansible_spec/pull/115) by [seiji](https://github.com/seiji)
- Merge [#113 Make ENV variables override SSH config file options](https://github.com/volanja/ansible_spec/pull/113) by [Jonnymcc](https://github.com/Jonnymcc)

# v0.2.22
- Merge [#111 fix sudo directive for after Ansible 1.9](https://github.com/volanja/ansible_spec/pull/111) by [katsuhisa91](https://github.com/katsuhisa91)

# v0.2.21
- Merge [#103 Parse the full included playbook](https://github.com/volanja/ansible_spec/pull/103) by [agx](https://github.com/agx)

# v0.2.20
- Merge [#101 Added feature set path to group_vars and host_vars](https://github.com/volanja/ansible_spec/pull/101) by [rbramwell](https://github.com/rbramwell)
- Merge [#99 Unbreak 'serverspec:all' if groups with no hosts exist](https://github.com/volanja/ansible_spec/pull/99) by [agx](https://github.com/agx)


# v0.2.19
- Merge [#98 delete directory('roles','more_roles') after execute rpsec](https://github.com/volanja/ansible_spec/pull/98) by volanja
- Merge [#97 Add local connection test path](https://github.com/volanja/ansible_spec/pull/97) by [mtoriumi](https://github.com/mtoriumi)

# v0.2.18
- Merge [#96 Handle roles_path for role dependencies as well](https://github.com/volanja/ansible_spec/pull/96) by [agx](https://github.com/agx)

# v0.2.17
- Merge [#90 Check if all array elements have a name](https://github.com/volanja/ansible_spec/pull/90) by [agx](https://github.com/agx)
- Merge [#91 Parse roledirs from ansible.cfg](https://github.com/volanja/ansible_spec/pull/91) by [agx](https://github.com/agx)
- Merge [#92 should use winrm < v2.1.1 at ruby 1.9.3](https://github.com/volanja/ansible_spec/pull/92) by volanja
- Merge [#93 #89 use ENV['SSH_CONFIG_FILE'] or ssh_args at ansible_cfg](https://github.com/volanja/ansible_spec/pull/93) by volanja  
Original idea [#89 set a option, it can select file of SSH-configration](https://github.com/volanja/ansible_spec/pull/89) by [gigathlete](https://github.com/gigathlete)
- Merge [add test at ruby 2.4.0 & 2.3.3 & 2.2.6 (drop test 2.3.1 & 2.2.5)](https://github.com/volanja/ansible_spec/pull/94) by volanja

# v0.2.16
- Merge [#88 fix nil dependencies](https://github.com/volanja/ansible_spec/pull/88) by [developerinlondon](https://github.com/developerinlondon)
- Merge [#87 added .DS_Store to gitignore](https://github.com/volanja/ansible_spec/pull/87) by [developerinlondon](https://github.com/developerinlondon)
- Merge [#85 #84 modify variable expansion](https://github.com/volanja/ansible_spec/pull/85) by volanja
- Merge [#84 On errors print the playbook name](https://github.com/volanja/ansible_spec/pull/84) by [agx](https://github.com/agx)
- Merge [#83 Handle "simple" role dependencies](https://github.com/volanja/ansible_spec/pull/83) by [agx](https://github.com/agx)
- Merge [#82 Handle directories with vars as well](https://github.com/volanja/ansible_spec/pull/82) by [agx](https://github.com/agx)
- Merge [#78 should use json v1.8.3 at ruby 1.9.3](https://github.com/volanja/ansible_spec/pull/78) by volanja
- Merge [#77 support ansible_host, ansible_user, ansible_port](https://github.com/volanja/ansible_spec/pull/77) by volanja

# v0.2.15
- Merge [Add .rspec when run `ansiblespec-init`](https://github.com/volanja/ansible_spec/pull/76) by volanja

# v0.2.14
- Merge [Fix NoMethodError at get_variables](https://github.com/volanja/ansible_spec/pull/75) by [hico-horiuchi](https://github.com/hico-horiuchi)

# v0.2.13
- Merge [Dynamic Inventory use multiple hosts, lookup group children dependency group_vars.](https://github.com/volanja/ansible_spec/pull/73) by [guyon](https://github.com/guyon)

# v0.2.12
- Merge [Support deep merge for variable](https://github.com/volanja/ansible_spec/pull/72) by [okamototk](https://github.com/okamototk)

# v0.2.11
- Merge [Support Windows](https://github.com/volanja/ansible_spec/pull/68) by [takuyakawabuchi](https://github.com/takuyakawabuchi)

# v0.2.10
- Merge [support group and host variables without yml extention.](https://github.com/volanja/ansible_spec/pull/66) by [okamototk](https://github.com/okamototk)

# v0.2.9
- Merge [#65 return an empty array when the group has no hosts in it](https://github.com/volanja/ansible_spec/pull/65) by [franmrl](https://github.com/franmrl)

# v0.2.8
- Merge [#60 Support ansible variable in playbook partially](https://github.com/volanja/ansible_spec/pull/60) by [okamototk](https://github.com/okamototk)

# v0.2.7
- Fix [#55 Connection fails where dynamic inventory has basic host list](https://github.com/volanja/ansible_spec/issues/55) by [temyers](https://github.com/temyers)
- Merge [#59 Issue55 fail dynamic inventory](https://github.com/volanja/ansible_spec/pull/59)

# v0.2.6
- Merge [#53 Execute tests for dependent roles](https://github.com/volanja/ansible_spec/pull/53) by [Gerrrr](https://github.com/Gerrrr)

# v0.2.5
- Merge [#51 Handle hosts which are not assigned to any group](https://github.com/volanja/ansible_spec/pull/51) by [Gerrrr](https://github.com/Gerrrr)

# v0.2.4
- Fix [#50 do not fail on no hosts matched](https://github.com/volanja/ansible_spec/pull/50) by [phiche](https://github.com/phiche)

# v0.2.3
- Fix [#47 NoMethodError: undefined method 'each' for nil:NilClass if inventory has "roles"=>[]](https://github.com/volanja/ansible_spec/issues/47) by [phiche](https://github.com/phiche)

# v0.2.2
- Fix [#43 Enable to set only either of `PLAYBOOK` or `INVENTORY`.](https://github.com/volanja/ansible_spec/issues/43) by [akagisho](https://github.com/akagisho)
- Fix [#45 ansible_spec cannot use ec2.py dynamic inventory](https://github.com/volanja/ansible_spec/issues/45) by [phiche](https://github.com/phiche)

# v0.2.1
- fix [#27 check name on playbook](https://github.com/volanja/ansible_spec/issues/27)
- Add Test
  - 2.1.6
  - 2.2.2
- Delete Test
  - 2.1.0
  - 2.1.1
  - 2.2.0
  - 2.2.1

# v0.2
- fix [#24 Support ENV](https://github.com/volanja/ansible_spec/issues/24)

```
Example:
$ PLAYBOOK=site.yml INVENTORY=hosts rake serverspec:Ansible-Sample-TDD 
```

# v0.1.1

fix [#22 NameError: uninitialized constant AnsibleSpec::Open3](https://github.com/volanja/ansible_spec/issues/22)


# v0.1

- Support Serverspec v2
- Simplification Rakefile and Modularization. Because of Improvement of testability.
- Support InventoryParameters  
  - ansible_ssh_port
  - ansible_ssh_user
  - ansible_ssh_host
  - ansible_ssh_private_key_file
- Support [hostlist expressions](http://docs.ansible.com/intro_inventory.html#hosts-and-groups)
- Support DynamicInventory

This gem created template file until v0.0.1.4,  
But it was modularized on v0.1. Because module is easy to unit-test and Rakefile is simple.  

If you want old release that can create template, use `gem install ansible_spec -v 0.0.1.4`  
But I can't support(Bug fix, Add feature) old release.  

## VersionUp from v0.0.1.4 to v0.1

```
$ rm Rakefile
$ rm spec/spec_helper.md
$ ansiblespec-init 
```

# v0.0.1.3
- Support `.ansiblespec`


