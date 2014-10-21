require 'puppet'
require 'rexml/document'
include REXML

Puppet::Type.type(:firewalld_zone).provide :zoneprovider do
    desc "The zone config manipulator"

    commands :firewall => 'firewall-cmd'

    mk_resource_methods
 
    def create
        doc = REXML::Document.new
        doc << REXML::XMLDecl.default
        zone = doc.add_element 'zone'

        if @resource[:target]
          zone.add_attribute('target', @resource[:target])
        end

        if @resource[:short]
          short = zone.add_element 'short'
          short.text = @resource[:short]
        end

        if @resource[:description]
          short = zone.add_element 'description'
          short.text = @resource[:description]
        end

        if @resource[:interfaces]
          @resource[:interfaces].each do |interface|
            # TODO: firewall-cmd --get-zone-of-interface...
            iface = zone.add_element 'interface'
            iface.add_attribute('name', interface)
          end
        end

        if @resource[:sources]
          @resource[:sources].each do |source|
            # TODO: firewall-cmd --get-zone-of-source...
            src = zone.add_element 'source'
            src.add_attribute('address', source)
          end
        end

        if @resource[:services]
          @resource[:services].each do |service|
            srv = zone.add_element 'service'
            srv.add_attribute('name', service)
          end
        end

        if @resource[:ports]
          @resource[:ports].each do |port|
            prt = zone.add_element 'port'
            prt.add_attribute('port', port['port'])
            prt.add_attribute('protocol', port['protocol'])
          end
        end

        if @resource[:icmp_blocks]
          @resource[:icmp_blocks].each do |icmp_block|
            iblk = zone.add_element 'icmp-block'
            iblk.add_attribute('name', icmp_block)
          end
        end

        if @resource[:masquerade]
            zone.add_element 'masquerade'
        end

        if @resource[:forward_ports]
          @resource[:forward_ports].each do |forward_port|
            fw_prt = zone.add_element 'forward-port'
            fw_prt.add_attribute('port', forward_port['port'])
            fw_prt.add_attribute('protocol', forward_port['protocol'])
            if forward_port['to_port']
              fw_prt.add_attribute('to-port', forward_port['to_port'])
            end
            if forward_port['to_addr']
              fw_prt.add_attribute('to-addr', forward_port['to_addr'])
            end
          end
        end

        if @resource[:rich_rules]
          @resource[:rich_rules].each do |rich_rule|
            rule = zone.add_element 'rule'
            if rich_rule['family']
              rule.add_attribute('family', rich_rule['family'])
            end

            if rich_rule['source']
              source = rule.add_element 'source'
              source.add_attribute('address', rich_rule['source']['address'])
              if rich_rule['source']['invert']
                source.add_attribute('invert', 'true')
              end
            end

            if rich_rule['destination']
              dest = rule.add_element 'destination'
              dest.add_attribute('address', rich_rule['destination']['address'])
              if rich_rule['destination']['invert']
                dest.add_attribute('invert', 'true')
              end
            end

            if rich_rule['service']
              service = rule.add_element 'service'
              service.add_attribute('name', rich_rule['service'])
            end

            if rich_rule['port']
              port = rule.add_element 'port'
              port.add_attribute('port', rich_rule['port']['portid'])
              port.add_attribute('protocol', rich_rule['port']['protocol'])
            end

            if rich_rule['protocol']
              protocol = rule.add_element 'protocol'
              protocol.add_attribute('value', rich_rule['protocol'])
            end

            if rich_rule['icmp_block']
              icmp_block = rule.add_element 'icmp-block'
              icmp_block.add_attribute('name', rich_rule['icmp_block'])
            end

            if rich_rule['masquerade']
              rule.add_element 'masquerade'
            end

            if rich_rule['forward_port']
              fw_port = rule.add_element 'forward-port'
              fw_port.add_attribute('port', rich_rule['forward_port']['portid'])
              fw_port.add_attribute('protocol', rich_rule['forward_port']['protocol'])
              if rich_rule['forward_port']['to_port']
                fw_port.add_attribute('to-port', rich_rule['forward_port']['to_port'])
              end
              if rich_rule['forward_port']['to_addr']
                fw_port.add_attribute('to-addr', rich_rule['forward_port']['to_addr'])
              end
            end

            if rich_rule['log']
              log = rule.add_element 'log'
              if rich_rule['log']['prefix']
                log.add_attribute('prefix', rich_rule['log']['prefix'])
              end
              if rich_rule['log']['level']
                log.add_attribute('level', rich_rule['log']['level'])
              end
              if rich_rule['log']['limit']
                limit = log.add_element 'limit'
                limit.add_attribute('value', rich_rule['log']['limit'])
              end
            end

            if rich_rule['audit']
              audit = rule.add_element 'audit'
              if rich_rule['audit']['limit']
                limit = audit.add_element 'limit'
                limit.add_attribute('value', rich_rule['audit']['limit'])
              end
            end

            if rich_rule['action']
              action = rule.add_element rich_rule['action']['action_type']
              if rich_rule['action']['reject_type']
                action.add_attribute('type', rich_rule['action']['reject_type'])
              end
              if rich_rule['action']['limit']
                limit = action.add_element 'limit'
                limit.add_attribute('value', rich_rule['action']['limit'])
              end
            end
          end
        end

        path = '/etc/firewalld/zones/' + @resource[:name] + '.xml'
        file = File.open(path, "w+")
	doc.write( file, 2 )
        file.close
        firewall('--reload')
    end
 
    def destroy
        path = '/etc/firewalld/zones' + @resource[:name] + '.xml'
        File.delete(path)
    end
 
    def exists?
        # TODO: verify correctness of zone xml file https://fedorahosted.org/firewalld/ticket/8
        path = '/etc/firewalld/zones/' + @resource[:name] + '.xml'
        File.exists?(path)
    end
end
