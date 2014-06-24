# Firewalld module

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

# Class: firewalld
#
# This class installs/runs firewalld.
#
# Requires:
#
# Nothing.
#
class firewalld {

	package { 'firewalld':
		ensure => present,	# install package
	}

	# iptables service that comes with rhel/centos
	service { 'iptables':		# don't let this interfere
		enable => false,	# don't start on boot
		ensure => stopped,	# ensure it's stopped
	}

	service { 'ip6tables':		# don't let this interfere
		enable => false,	# don't start on boot
		ensure => stopped,	# ensure it's stopped
	}

	service { 'firewalld':
		ensure     => running,	# ensure it's running
		enable     => true,	# start on boot
		hasstatus  => true,	# init script has 'status' command
		hasrestart => true,	# init script has 'restart' command
		require => [
			Package['firewalld'],
			File['/etc/firewalld/firewalld.conf'],	# require this file
			Service['iptables', 'ip6tables'],	# ensure it's stopped
		],
	}

}

# Class firewalld::configuration
#
# This class configures firewalld.
#
# == Parameters:
#
# $default_zone::	Default zone.
# $minimal_mark::	Marks up to this minimum are free for use.
# $cleanup_on_exit::	If set to no or false the firewall configuration will
#			not get cleaned up on exit or stop of firewalld
# $lockdown::		If set to enabled, firewall changes with the D-Bus
#			interface will be limited to applications that
#			are listed in the lockdown whitelist.
# $IPv6_rpfilter::	Performs a reverse path filter test on a packet for
#			IPv6. If a reply to the packet would be sent via the
#			same interface that the packet arrived on, the packet
#			will match and be accepted, otherwise dropped.
#
# Sample Usage:
#
#	class {'firewalld::configuration':
#		default_zone    =>      'dmz',
#		minimal_mark    =>      '200',
#	}
#
class firewalld::configuration (
	$default_zone		= 'public',
	$minimal_mark		= '100',
	$cleanup_on_exit	= 'yes',
	$lockdown		= 'no',
	$IPv6_rpfilter		= 'yes'
) {
	include firewalld

	file { '/etc/firewalld/':
		ensure	=> directory,		# make sure this is a directory
		#recurse	=> true,		# recursively manage directory
		#purge	=> true,		# purge all unmanaged files
		#force	=> true,		# also purge subdirs and links
		owner	=> root,
		group	=> root,
		mode	=> 750,
		require	=> Package['firewalld'], # make sure package is installed
		notify	=> Service['firewalld'], # restart service
	}

	file { '/etc/firewalld/firewalld.conf':
		ensure	=> file,
		#source	=> "puppet:///modules/firewalld/firewalld.conf.default",
		content	=> template("firewalld/firewalld.conf.erb"),
		owner 	=> root,
		group	=> root,
		mode	=> 640,
		require	=> Package['firewalld'], # make sure package is installed
		notify	=> Service['firewalld'], # restart service
	}
}

class firewalld::zone::base {
	include firewalld
	file { '/etc/firewalld/zones/':
		ensure	=> directory,		# make sure this is a directory
		recurse	=> true,		# recursively manage directory
		purge	=> true,		# purge all unmanaged files
		force	=> true,		# also purge subdirs and links
		owner	=> root,
		group	=> root,
		mode	=> 750,
		require	=> Package['firewalld'],
		notify	=> Service['firewalld'],
	}
}

#$forward_ports = [{
#		comment		=>  'my forward to somewhere',
#		portid		=> '123',
#		protocol	=> 'tcp',
#		to_port		=> '321',
#		to_addr		=> '1.2.3.4',},],

define firewalld::zone(
	$short = "",			# short readable name
	$description = "",		# long description of zone
	$interfaces = [],		# bind an interfaces to a zone
	$sources = [],			# bind a source address or source address range ("address/mask") to a zone
	$ports = {},			# e.g. {"ssh port" => {"22" => "tcp"}}
	$services = [],			# predefined firewalld services, e.g. ["ssh", "dhcpv6-client"]
	$icmp_blocks = [],		# predefined icmp-types to block, e.g. ["echo-reply"]
	$masquerade = false,		# enable masquerading ?
	$forward_ports = [],		#
) {
	include firewalld::zone::base

	file { "/etc/firewalld/zones/${name}.xml":
		content	=> template('firewalld/zone.xml.erb'),
		owner	=> root,
		group	=> root,
		mode	=> 644,
		require	=> Package['firewalld'],
		notify	=> Service['firewalld'],
	}
}
