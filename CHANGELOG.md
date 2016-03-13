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


