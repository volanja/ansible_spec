# v0.1.1
fix #22


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


