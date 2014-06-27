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
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# Class: firewalld::zone::base
#
# This class ensures that /etc/firewalld/zones/ exists.
#
class firewalld::zone::base {
	include firewalld
	file { '/etc/firewalld/zones/':
		ensure	=> directory,		# make sure this is a directory
		recurse	=> true,		# recursively manage directory
		purge	=> true,		# purge all unmanaged files
		force	=> true,		# also purge subdirs and links
		owner	=> root,
		group	=> root,
		mode	=> '0750',
		require	=> Package['firewalld'],
		notify	=> Service['firewalld'],
	}
}

# resource type firewalld::zone
#
# This defines a zone configuration.
#
# == Parameters:
#
# $short::	 	short readable name
# $description::	long description of zone
# $interfaces::		list of interfaces to bind to a zone
# $sources::		list of source addresses or source address
#			ranges ("address/mask") to bind to a zone
# $ports::		list of ports to open
# $services::		list of predefined firewalld services
# $icmp_blocks::	list of predefined icmp-types to block
# $masquerade::		enable masquerading ?
# $forward_ports::	list of ports to forward to other port and/or machine
#
# Sample Usage:
#
#	firewalld::zone { "custom":
#		description	=> "This is an example zone",
#		services	=> ["ssh", "dhcpv6-client"],
#		ports		=> [{
#				comment		=> "for our dummy service",
#				port		=> "1234",
#				protocol	=> "tcp",},],
#		masquerade	=> true,
#		forward_ports	=> [{
#			comment		=> 'forward 123 to other machine',
#			portid		=> '123',
#			protocol	=> 'tcp',
#			to_port		=> '321',
#			to_addr		=> '1.2.3.4',},],}
#
define firewalld::zone(
	$short = "",
	$description = "",
	$interfaces = [],
	$sources = [],
	$ports = [],
	$services = [],
	$icmp_blocks = [],
	$masquerade = false,
	$forward_ports = [],
) {
	include firewalld::zone::base

	file { "/etc/firewalld/zones/${name}.xml":
		content	=> template('firewalld/zone.xml.erb'),
		owner	=> root,
		group	=> root,
		mode	=> '0644',
		require	=> Package['firewalld'],
		notify	=> Service['firewalld'],
	}
}
