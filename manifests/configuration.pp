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


# == Class: firewalld::configuration
#
# This class configures firewalld.
#
# === Parameters
#
# [*default_zone*]
#   Default zone.
# [*minimal_mark*]
#   Marks up to this minimum are free for use.
# [*cleanup_on_exit*]
#   If set to no or false the firewall configuration will not get cleaned up
#   on exit or stop of firewalld
# [*lockdown*]
#   If set to enabled, firewall changes with the D-Bus interface will be
#   limited to applications that are listed in the lockdown whitelist.
# [*IPv6_rpfilter*]
#   Performs a reverse path filter test on a packet for IPv6. If a reply to
#   the packet would be sent via the same interface that the packet arrived on,
#   the packet will match and be accepted, otherwise dropped.
#
# === Examples
#
#  class {'firewalld::configuration':
#    default_zone    =>      'custom',}
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
		mode	=> '0750',
		require	=> Package['firewalld'], # make sure package is installed
		notify	=> Service['firewalld'], # restart service
	}

	file { '/etc/firewalld/firewalld.conf':
		ensure	=> file,
		#source	=> "puppet:///modules/firewalld/firewalld.conf.default",
		content	=> template("firewalld/firewalld.conf.erb"),
		owner 	=> root,
		group	=> root,
		mode	=> '0640',
		require	=> Package['firewalld'], # make sure package is installed
		notify	=> Service['firewalld'], # restart service
	}
}
