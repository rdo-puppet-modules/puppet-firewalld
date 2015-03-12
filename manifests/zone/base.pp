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
# It is used in firewalld::zone and doesn't need to be used on its own.
#
class firewalld::zone::base (
  $purge_zones = true
) {
  file { '/etc/firewalld/zones/':
    ensure  => directory,    # make sure this is a directory
    recurse => true,         # recursively manage directory
    purge   => $purge_zones, # purge all unmanaged files, unless overridden in ENC (i.e. Foreman)
    force   => true,         # also purge subdirs and links
    owner   => root,
    group   => root,
    mode    => '0750',
    require => Package['firewalld'],
    notify  => Service['firewalld'],
  }
}
