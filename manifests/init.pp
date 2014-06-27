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

# == Class: firewalld
#
# This class installs/runs firewalld.
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
