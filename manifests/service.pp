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

# == Class: firewalld::service::base
#
# This class ensures that /etc/firewalld/services/ exists.
# It is used in firewalld::service and doesn't need to be used on its own.
#
class firewalld::service::base {

	#include firewalld

	file { '/etc/firewalld/services/':
		ensure	=> directory,		# make sure this is a directory
		owner	=> root,
		group	=> root,
		mode	=> '0750',
		require	=> Package['firewalld'],
		notify	=> Service['firewalld'],
	}
}

# == Define: firewalld::service
#
# This defines a service configuration.
# You usually don't need this, you can simply add ports to zone (firewalld::zone).
# Result is a /etc/firewalld/services/${name}.xml file, where ${name}
# is name of the class. See also firewalld.service (5) man page.
#
# === Parameters
#
# [*short*]		short readable name
# [*description*]	long description of service
# [*ports*]
#   list of ports to open
#	ports  => [{
#		port     => mandatory, string, e.g. '1234'
#		protocol => mandatory, string, e.g. 'tcp' },...]
# [*modules*]		list of kernel netfilter helpers to load
# [*destination*]
#   specifies destination network as a network IP address
#   (optional with /mask), or a plain IP address.
#	destination  => {
#		ipv4 => string, mandatory to specify ipv4 and/or ipv6
#		ipv6 => string, mandatory to specify ipv4 and/or ipv6 }
#
# === Examples
#
#  firewalld::service { 'dummy':
#	description	=> 'My dummy service',
#	ports		=> [{port => '1234', protocol => 'tcp',},],
#	modules		=> ['some_module_to_load'],
#	destination	=> {ipv4 => '224.0.0.251', ipv6 => 'ff02::fb'},}
#
define firewalld::service(
	$short = '',
	$description = '',
	$ports = [],
	$modules = [],
	$destination = {},
) {

	include firewalld::service::base
	include firewalld::configuration

	file { "/etc/firewalld/services/${name}.xml":
		content	=> template('firewalld/service.xml.erb'),
		owner	=> root,
		group	=> root,
		mode	=> '0644',
		require	=> Package['firewalld'],
		notify	=> Service['firewalld'],
	}
}
