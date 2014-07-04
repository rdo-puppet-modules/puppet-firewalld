# here is some example usage for some of the firewalld classes and types
# run this with 'puppet apply misc-example.pp'

class {'firewalld::configuration':
        default_zone    =>      'custom',
}

# define a zone
firewalld::zone { 'custom':
	description	=> 'This is an example zone',
	services	=> ['ssh', 'dhcpv6-client'],
	ports		=> [{
			comment		=> 'for our dummy service',
			port		=> '1234',
			protocol	=> 'tcp',},],
	masquerade	=> true,
	forward_ports	=> [{
			comment		=> 'forward 123 to other machine',
			portid		=> '123',
			protocol	=> 'tcp',
			to_port		=> '321',
			to_addr		=> '1.2.3.4',},],
	rich_rules	=> [{
			family		=> 'ipv4',
			source		=> {
				address		=> '1.1.1.1',
				invert		=> true,},
			destination		=> {
				address		=> '2.2.2.2/24',},
#			service		=> 'ssh',
			port		=> {
				portid		=> '123-321',
				protocol	=> 'udp',},
#			protocol	=> 'ah',
#			icmp_block	=> 'router-solicitation',
#			masquerade	=> true,
#			forward_port	=> {
#				portid		=> '555',
#				protocol	=> 'udp',
#				to_port		=> '666',
#				to_addr		=> '6.6.6.6',},
			log		=> {
				prefix		=> 'testing',
				level		=> 'notice',
				limit		=> '3/s',},
			audit		=> {
				limit		=> '2/h',},
#			accept		=> true,
			reject		=> {
				type		=> 'icmp-host-prohibited',},
#			drop		=> {},
			},],

}
