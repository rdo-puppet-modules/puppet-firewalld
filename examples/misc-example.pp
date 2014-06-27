# here is some example usage for some of the firewalld classes and types
# run this with 'puppet apply misc-example.pp'

class {'firewalld::configuration':
        default_zone    =>      'custom',
}

# define a zone
firewalld::zone { "custom":
	description	=> "This is an example zone",
	services	=> ["ssh", "dhcpv6-client"],
	ports		=> [{
			comment		=> "for our dummy service",
			port		=> "1234",
			protocol	=> "tcp",},],
	masquerade	=> true,
	forward_ports	=> [{
			comment		=> 'forward 123 to other machine',
			portid		=> '123',
			protocol	=> 'tcp',
			to_port		=> '321',
			to_addr		=> '1.2.3.4',},
		],
}
