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

# == Class: firewalld::zone::base
#
# This class ensures that /etc/firewalld/zones/ exists.
#
class firewalld::zone::base {

	#include firewalld

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

# == Define: firewalld::zone
#
# This defines a zone configuration.
#
# === Parameters
#
# [*target*]		can be one of {'ACCEPT', '%%REJECT%%', 'DROP'}
#   Used to accept, reject or drop every packet that doesn't match any rule
#   (port, service, etc.). Default (when target is not specified) is reject.
# [*short*]		short readable name
# [*description*]	long description of zone
# [*interfaces*]	list of interfaces to bind to a zone
# [*sources*]		list of source addresses or source address
#			ranges ("address/mask") to bind to a zone
# [*ports*]		list of ports to open
#   ports  => [{
#          comment  => optional, string
#          port     => mandatory, string, e.g. '1234'
#          protocol => mandatory, string, e.g. 'tcp'
#              },...]
# [*services*]		list of predefined firewalld services
# [*icmp_blocks*]	list of predefined icmp-types to block
# [*masquerade*]	enable masquerading ?
# [*forward_ports*]	list of ports to forward to other port and/or machine
#   forward_ports  => [{
#           comment  => optional, string
#           portid   => mandatory, string, e.g. '123'
#           protocol => mandatory, string, e.g. 'tcp'
#           to_port  => mandatory to specify either to_port or/and to_addr
#           to_addr  => mandatory to specify either to_port or/and to_addr
#                      },...]
# [*rich_rules*]	list of rich language rules (firewalld.richlanguage(5))
#   You have to specify one (and only one)
#   of {service, port, protocol, icmp_block, masquerade, forward_port}
#   and one (and only one) of {accept, reject, drop}
#   family - 'ipv4' or 'ipv6', optional, see Rule in firewalld.richlanguage(5)
#   source  => {  optional, see Source in firewalld.richlanguage(5)
#        address  => mandatory, string, e.g. '192.168.1.0/24'
#        invert   => optional, bool, e.g. true }
#   destination => { optional, see Destination in firewalld.richlanguage(5)
#        address => mandatory, string
#        invert  => optional, bool, e.g. true }
#   service - string, see Service in firewalld.richlanguage(5)
#   port => { see Port in firewalld.richlanguage(5)
#     portid   => mandatory
#     protocol => mandatory }
#   protocol - string, see Protocol in firewalld.richlanguage(5)
#   icmp_block - string, see ICMP-Block in firewalld.richlanguage(5)
#   masquerade - bool, see Masquerade in firewalld.richlanguage(5)
#   forward_port => { see Forward-Port in firewalld.richlanguage(5)
#           portid   => mandatory
#           protocol => mandatory
#           to_port  => mandatory to specify either to_port or/and to_addr
#           to_addr  => mandatory to specify either to_port or/and to_addr }
#   log => {   see Log in firewalld.richlanguage(5)
#     prefix => string, optional
#     level  => string, optional
#     limit  => string, optional }
#   audit => {  see Audit in firewalld.richlanguage(5)
#     limit => string, optional }
#   accept - any value, e.g. true, see Action in firewalld.richlanguage(5)
#   reject => { see Action in firewalld.richlanguage(5)
#       type => string, optional }
#   drop - any value, e.g. true, see Action in firewalld.richlanguage(5)
#
# === Examples
#
#  firewalld::zone { "custom":
#	description	=> "This is an example zone",
#	services	=> ["ssh", "dhcpv6-client"],
#	ports		=> [{
#			comment		=> "for our dummy service",
#			port		=> "1234",
#			protocol	=> "tcp",},],
#	masquerade	=> true,
#	forward_ports	=> [{
#			comment		=> 'forward 123 to other machine',
#			portid		=> '123',
#			protocol	=> 'tcp',
#			to_port		=> '321',
#			to_addr		=> '1.2.3.4',},],
#	rich_rules	=> [{
#			family		=> 'ipv4',
#			source		=> {
#				address		=> '192.168.1.0/24',
#				invert		=> true,},
#			port		=> {
#				portid		=> '123-321',
#				protocol	=> 'udp',},
#			log		=> {
#				prefix		=> 'local',
#				level		=> 'notice',
#				limit		=> '3/s',},
#			audit		=> {
#				limit		=> '2/h',},
#			reject		=> {
#				type		=> 'icmp-host-prohibited',},
#			},],}

define firewalld::zone(
	$target = '',
	$short = '',
	$description = '',
	$interfaces = [],
	$sources = [],
	$ports = [],
	$services = [],
	$icmp_blocks = [],
	$masquerade = false,
	$forward_ports = [],
	$rich_rules = [],
) {

	include firewalld::zone::base

	if "${rich_rules}" != [] {
		# TODO: assert there's one (and only one of)
		# {service, port, protocol, icmp_block, masquerade, forward_port}
		# and one (and only one of) {accept, reject, drop}
		# (So far I have no idea how to do that)
	}

	file { "/etc/firewalld/zones/${name}.xml":
		content	=> template('firewalld/zone.xml.erb'),
		owner	=> root,
		group	=> root,
		mode	=> '0644',
		require	=> Package['firewalld'],
		notify	=> Service['firewalld'],
	}
}
