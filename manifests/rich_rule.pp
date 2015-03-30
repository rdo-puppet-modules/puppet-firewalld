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

# == Define: firewalld::rich_rule
#  to_addr    => 'public',
#  rich_rules  => [{
#      family    => 'ipv4',
#      source    => {
#        address    => '192.168.1.0/24',
#        invert    => true,},
#      port    => {
#        portid    => '123-321',
#        protocol  => 'udp',},
#      log    => {
#        prefix    => 'local',
#        level    => 'notice',
#        limit    => '3/s',},
#      audit    => {
#        limit    => '2/h',},
#      action    => {
#        action_type  => 'reject',
#        reject_type  => 'icmp-host-prohibited',},
#      },],}
#
define firewalld::rich_rule(
  $zone,
  $ensure     = present,
  $rich_rules = [],
) {

  include firewalld::configuration

  firewalld_rich_rule { $name:
    ensure     => $ensure,
    zone       => $zone,
    rich_rules => $rich_rules,
    notify     => Exec['firewalld::reload'],
    require    => Firewalld_zone[$zone],
  }
}
