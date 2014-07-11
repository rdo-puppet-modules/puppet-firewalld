# here you can see how to create a lockdown whitelist
# see firewalld.lockdown-whitelist (5) man page.
# You don't need this in most cases.

# this can be run with 'puppet apply lockdown-whitelist.pp'

class {'firewalld::configuration':
  lockdown          => 'yes',}

class {'firewalld::lockdown_whitelist':
  selinux_contexts  => ['system_u:system_r:NetworkManager_t:s0',
                        'system_u:system_r:virtd_t:s0-s0:c0.c1023'],
  commands          => ['/usr/bin/python -Es /usr/bin/firewall-config'],
  users             => [{username => 'me'},
                        {userid   => '1020'},],}
