# here is some example usage for some of the firewalld classes and types

class {'firewalld::configuration':
        default_zone    =>      'home',
        minimal_mark    =>      '666',
}

# define a zone
$zone = 'public'	# use a variable
firewalld::zone { "${zone}":
	description	=> "This is an example zone",
	services	=> ["ssh", "dhcpv6-client"],
	ports 		=> {
			"ssh" => {"22" => "tcp"},
			"dhcpv6 client" => {"546" => "udp"},
			"additional" => {"1025-65535" => "tcp"}},
	masquerade	=> true,
	forward_ports	=> [{
		comment		=>  'my forward to somewhere',
		portid		=> '123',
		protocol	=> 'tcp',
		to_port		=> '321',
		to_addr		=> '1.2.3.4',},],
}
