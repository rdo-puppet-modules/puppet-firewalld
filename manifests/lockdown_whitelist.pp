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

# == Class: firewalld::lockdown_whitelist
#
# Defines a lockdown whitelist, which contains selinux contexts, commands,
# users and user ids that are white-listed when firewalld lockdown feature
# is enabled. See class firewalld::configuration and
# firewalld.lockdown-whitelist (5) man page.
# Also http://fedoraproject.org/wiki/Features/FirewalldLockdown
# Result is a /etc/firewalld/lockdown-whitelist.xml file.
#
# === Parameters
#
# [*selinux_contexts*]  list of strings - security (SELinux) contexts
#                       of a running application or service.
# [*commands*]          list of commands. Command is a string - complete
#                       command line including path and also attributes.
# [*users*]
#   list of users
#	users => [{
#		username => string, mandatory to specify either username or userid
#		userid   => string, mandatory to specify either username or userid
#		},...]
#
# === Examples
#
#   class {'firewalld::lockdown_whitelist':
#	selinux_contexts  => ['system_u:system_r:NetworkManager_t:s0',
#                             'system_u:system_r:virtd_t:s0-s0:c0.c1023'],
#	commands          => ['/usr/bin/python -Es /usr/bin/firewall-config'],
#	users             => [{username => 'me'},],}
#
class firewalld::lockdown_whitelist(
	$selinux_contexts = [],
	$commands = [],
	$users = [],
) {
	include firewalld::configuration

	if "${users}" != [] {
		# TODO: assert there's one (and only one of) {username, userid}
	}

	file { '/etc/firewalld/lockdown-whitelist.xml':
		content	=> template('firewalld/lockdown-whitelist.xml.erb'),
		owner	=> root,
		group	=> root,
		mode	=> '0644',
		require	=> Package['firewalld'],
		notify	=> Service['firewalld'],
	}
}
