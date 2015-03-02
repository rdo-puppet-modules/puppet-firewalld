require 'puppet'

Puppet::Type.newtype(:firewalld_zone) do
  desc <<-EOT
      = Define: firewalld::zone

      This defines a zone configuration.
      Result is a /etc/firewalld/zones/${name}.xml file, where ${name}
      is name of the class. See also firewalld.zone (5) man page.

      === Examples

       firewalld::zone { "custom":
          description  => "This is an example zone",
          services     => ["ssh", "dhcpv6-client"],
          sources      => ["10.0.0.8", "192.168.18.22", "2001:DB8:0:f00d:/64", ],
          ports        => [
            {
                  port        => "1234",
                  protocol    => "tcp",
            },
          ],
          masquerade    => true,
          forward_ports => [
            {
                  port        => '123',
                  protocol    => 'tcp',
                  to_port     => '321',
                  to_addr     => '1.2.3.4',
            },
          ],
          rich_rules    => [
            {
                  family        => 'ipv4',
                  source        => {
                      address       => '192.168.1.0/24',
                      invert        => true,
                  },
                  port          => {
                      portid      => '123-321',
                      protocol    => 'udp',
                  },
                  log        => {
                      prefix       => 'local',
                      level        => 'notice',
                      limit        => '3/s',
                  },
                  audit        => {
                      limit        => '2/h',
                  },
                  action        => {
                      action_type    => 'reject',
                      reject_type    => 'icmp-host-prohibited',
                  },
            },
          ],
       }
  EOT
 
  ensurable

  newparam(:name) do
      desc "The name of the zone"
  end 

  newparam(:target) do
    desc <<-EOT
      Can be one of {'ACCEPT', '%%REJECT%%', 'DROP'}.
      Used to accept, reject or drop every packet that 
      doesn't match any rule (port, service, etc.).
      Default (when target is not specified) is reject.
    EOT
    newvalues('ACCEPT', '%%REJECT%%', 'DROP')
  end

  newparam(:short) do
      desc "short readable name"
  end

  newparam(:description) do
      desc "long description of zone"
  end

  newproperty(:interfaces, :array_matching => :all) do
      desc "list of interfaces to bind to a zone"
  end

  newproperty(:sources, :array_matching => :all) do
      desc <<-EOT
        list of source addresses or source address
        ranges ("address/mask") to bind to a zone
      EOT
  end

  newproperty(:ports, :array_matching => :all) do
      desc <<-EOT
        list of ports to open
          ports  => [
            {
              port     => mandatory, string, e.g. '1234'
              protocol => mandatory, string, e.g. 'tcp'
            },
            ...
          ]
      EOT

  end

  newproperty(:services, :array_matching => :all) do
      desc "list of predefined firewalld services"
  end

  newproperty(:icmp_blocks, :array_matching => :all) do
      desc "list of predefined icmp-types to block"
  end

  newproperty(:masquerade, :array_matching => :all) do
      desc "enable masquerading ?"
      newvalues(:true, :false)
      defaultto false
  end

  newproperty(:forward_ports, :array_matching => :all) do
      desc <<-EOT
        list of ports to forward to other port and/or machine
          forward_ports  => [
            {
              port     => mandatory, string, e.g. '123' or '123-125'
              protocol => mandatory, string, e.g. 'tcp'
              to_port  => mandatory to specify either to_port or/and to_addr
              to_addr  => mandatory to specify either to_port or/and to_addr
            },
            ...
          ]
      EOT
  end

  newproperty(:rich_rules, :array_matching => :all) do
      desc <<-EOT
        list of rich language rules (firewalld.richlanguage(5))
          You have to specify one (and only one)
          of service, port, protocol, icmp_block, masquerade, forward_port
          and one (and only one) of accept, reject, drop

            family - 'ipv4' or 'ipv6', optional, see Rule in firewalld.richlanguage(5)

            source  => {  optional, see Source in firewalld.richlanguage(5)
              address  => mandatory, string, e.g. '192.168.1.0/24'
              invert   => optional, bool, e.g. true
            }

            destination => { optional, see Destination in firewalld.richlanguage(5)
              address => mandatory, string
              invert  => optional, bool, e.g. true
            }

            service - string, see Service in firewalld.richlanguage(5)

            port => { see Port in firewalld.richlanguage(5)
              portid   => mandatory
              protocol => mandatory
            }

            protocol - string, see Protocol in firewalld.richlanguage(5)

            icmp_block - string, see ICMP-Block in firewalld.richlanguage(5)

            masquerade - bool, see Masquerade in firewalld.richlanguage(5)

            forward_port => { see Forward-Port in firewalld.richlanguage(5)
              portid   => mandatory
              protocol => mandatory
              to_port  => mandatory to specify either to_port or/and to_addr
              to_addr  => mandatory to specify either to_port or/and to_addr
            }

            log => {   see Log in firewalld.richlanguage(5)
              prefix => string, optional
              level  => string, optional
              limit  => string, optional
            }

            audit => {  see Audit in firewalld.richlanguage(5)
              limit => string, optional
            }

            action => {  see Action in firewalld.richlanguage(5)
              action_type => string, mandatory, one of 'accept', 'reject', 'drop'
              reject_type => string, optional, use with 'reject' action_type only
              limit       => string, optional
            }
      EOT
  end

end
