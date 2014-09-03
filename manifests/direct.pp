# Copyright (C) 2014 Red Hat, Inc.
# Author: Jiri Popelka <jpopelka@redhat.com>

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

# == Class: firewalld::direct
#
# This defines a direct configuration.
# It should be used only as a last resort when it's not possible to use
# firewalld::zone. You need to know the iptables internals,
# like tables and command line arguments.
# Result is a /etc/firewalld/direct.xml file, see firewalld.direct (5) man page.
#
# === Parameters
#
# [*chains*]
#   list of chains
#	ipv   - string, mandatory. IP family where the chain will be created.
#		Can be either "ipv4" or "ipv6".
#	table - string, optional (defaults to 'filter').
#		Name of table where the chain will be created.
#	chain - string, mandatory. Name of the chain, that will be created.
# [*rules*]
#   list of rules
#	ipv   - string, mandatory. IP family where the rule will be added.
#		Can be either "ipv4" or "ipv6".
#	table - string, optional (defaults to 'filter').
#		Name of table where the rule will be added.
#	chain - string, mandatory. Name of chain where the rule will be added.
#		If the chain name is a built-in chain, then the rule will be
#		added to <chain>_direct, else the supplied chain name is used.
#	priority - string, optional (defaults to '0'). Used to order rules.
#		Priority '0' means add rule on top of the chain, with a higher
#		priority the rule will be added further down. Rules with the
#		same priority are on the same level and the order of these
#		rules is not fixed and may change. If you want to make sure
#		that a rule will be added after another one, use a low priority
#		for the first and a higher for the following.
#	args  - string, mandatory.  iptables or ip6tables arguments.
# [*passthroughs*]
#   list of passthroughs
#	ipv   - string, mandatory. IP family where the rule will be added.
#		Can be either "ipv4" or "ipv6".
#	args  - string, mandatory.  iptables or ip6tables arguments.
#
# === Examples
#
#   class {'firewalld::direct':
#	chains	=> [{
#		ipv   => 'ipv4',
#		table => 'filter',
#		chain => 'mine',},],
#
#	rules	=> [{
#		ipv      => 'ipv4',
#		table    => 'filter',
#		chain    => 'mine',
#		priority => '1',
#		args     => "-j LOG --log-prefix 'my prefix'",},
#		    {
#		ipv      => 'ipv4',
#		table    => 'mangle',
#		chain    => 'PREROUTING',
#		args     => "-p tcp -m tcp --dport 123 -j MARK --set-mark 1",},],}
#
class firewalld::direct(
	$chains = [],
	$rules = [],
	$passthroughs = [],
) {
	include firewalld::configuration

	file { '/etc/firewalld/direct.xml':
		content	=> template('firewalld/direct.xml.erb'),
		owner	=> root,
		group	=> root,
		mode	=> '0644',
		require	=> Package['firewalld'],
		notify	=> Service['firewalld'],
	}
}
