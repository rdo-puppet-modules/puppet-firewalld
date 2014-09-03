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
		args     => "-p tcp -m tcp --dport 123 -j MARK --set-mark 1' -j DROP",},],
}
