# -*- coding: utf-8 -*-
# 
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = '''
  name: 3scale_inventory_plugin
  author: Jeremy Whiting (jwhiting@r e d h a t . c o m)
  short_description: CSV inventory source
  description:
  - Get inventory hosts from a CSV file
  options:
    csv_data_file:
      description: path of CSV file to read
      required: True
  notes:
    - None
'''

EXAMPLES = '''
ansible-playbook -i inventory -i hosts injector.yml
'''

from ansible.errors import AnsibleError
from ansible.plugins.inventory import BaseInventoryPlugin
from ansible.plugins.inventory import Constructable
from ansible.utils.display import Display
from ansible.inventory.data import InventoryData

display = Display()

class InventoryModule(BaseInventoryPlugin, Constructable):
   ''' Host inventory parser for ansible using 3Scale data file as source. '''

   NAME = '3Scale_inventory_plugin'

   def verify_file(self, path):
      """Return the possibility of a configuration file being consumable by this plugin."""
      valid = path.endswith('.csv') or path.endswith('.CSV')
      return valid

   def parse(self, inventory, loader, path, cache=True):
      super(InventoryModule, self).parse(inventory, loader, path, cache)
      display.debug("File lookup path: %s" % path)
      data_file = open( path, "r")
      hostsset = set()
      for line in data_file:
         hostsset.add(line.split(',')[0].lstrip('"').rstrip('"'))

      self.inventory.add_group('injector_target_hosts')
      for host in hostsset:
         self.inventory.add_host(host, 'injector_target_hosts')
         self.inventory.set_variable(host, 'ansible_host', host)
