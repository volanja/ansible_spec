#!/usr/bin/python

import ansible

def load_ansible(inv_file):
    inventory = None
    if ansible.__version__.startswith('1.'):
        from ansible.inventory import Inventory

        inventory = Inventory(inv_file)

    elif ansible.__version__.startswith('2.'):
        from ansible.inventory import Inventory
        from ansible.parsing.dataloader import DataLoader
        from ansible.vars import VariableManager

        loader = DataLoader()
        variable_manager = VariableManager()
        inventory = Inventory(loader=loader, variable_manager=variable_manager, host_list=inv_file)

    else:
        raise "Unsupported ansible version"

    return inventory
