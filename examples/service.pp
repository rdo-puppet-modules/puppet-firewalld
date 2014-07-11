# here you can see how to create a service configuration
# see also firewalld.service(5) man page
# You usually don't need this, you can simply add ports to zone.

# run this with 'puppet apply service.pp'

# define a service
firewalld::service { 'dummy':
	description	=> 'My dummy service',
	ports		=> [{port => '1234', protocol => 'tcp',},],
	modules		=> ['some_module_to_load'],
	destination	=> {ipv4 => '224.0.0.251', ipv6 => 'ff02::fb'},
}
