# here you can see how to create a direct configuration
# see also firewalld.direct(5) man page

# this can be run with 'puppet apply direct.pp'

class {'firewalld::direct':
	chains	=> [{
		ipv   => 'ipv4',
		#table => 'filter',
		chain => 'mine',},],

	rules	=> [{
		ipv      => 'ipv4',
		#table    => 'filter',
		chain    => 'mine',
		#priority => '1',
		args     => "-j LOG --log-prefix 'my prefix'",},
		    {
		ipv      => 'ipv4',
		table    => 'mangle',
		chain    => 'PREROUTING',
		args     => "-p udp --sport 53 -m u32 --u32 '0&amp;0x0F000000=0x05000000 &amp;&amp; 22&amp;0xFFFF@16=0x01020304' -j DROP",},],
}
