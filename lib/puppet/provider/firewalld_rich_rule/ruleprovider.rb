require 'puppet'
require 'rexml/document'
include REXML

Puppet::Type.type(:firewalld_rich_rule).provide :ruleprovider do
    desc "The rule config manipulator"

    commands :firewall => 'firewall-cmd'

    mk_resource_methods

    def create_elements
      elements = REXML::Element.new 'rich-rules'
      @resource[:rich_rules].each do |rich_rule|
        rule = elements.add_element 'rule'
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
      return elements
    end

    def create
        path = '/etc/firewalld/zones/' + @resource[:zone] + '.xml'
        if File.exists?(path)
          file = File.open(path, "r+")
          doc = REXML::Document.new(file,{:ignore_whitespace_nodes => :all})
          rules = self.create_elements
          rules.each_element('//rule') do |rule|
            found = false
            doc.each_element('//zone/rule') do |element|
              if rule.to_s == element.to_s
                found = true
              end
            end
            if found == false
              doc.root().add_element(rule)
            end
          end
          file.rewind()
          doc.write(file, 2)
          file.close
        else
          raise(Puppet::Error, "Zone does not exist")
        end
    end
 
    def destroy
        path = '/etc/firewalld/zones/' + @resource[:zone] + '.xml'
        if File.exists?(path)
          file = File.open(path, "r+")
          doc = REXML::Document.new(file,{:ignore_whitespace_nodes => :all})
          rules = self.create_elements
          rules.each_element('//rule') do |rule|
            doc.each_element('//zone/rule') do |element|
              if rule.to_s == element.to_s
                found = true
                doc.root().delete_element(element)
              end
            end
          end
          file.truncate(0)
          doc.write(file, 2)
          file.close
        else
          raise(Puppet::Error, "Zone does not exist")
        end
    end

    def exists?
        path = '/etc/firewalld/zones/' + @resource[:zone] + '.xml'
        if File.exists?(path)
          file = File.open(path, "r")
          doc = REXML::Document.new(file,{:ignore_whitespace_nodes => :all})
          rules = self.create_elements
          rules.each_element('//rule') do |rule|
            rule_found = false
            doc.each_element('//zone/rule') do |element|
              if rule.to_s == element.to_s
                 rule_found = true
              end
            end
            if rule_found == false
              return false
            end
          end
          return true
        end
        return false
    end

    # rich_rules getter
    def rich_rules
      path = '/etc/firewalld/zones/' + @resource[:zone] + '.xml'


      zonename = File.basename(path, ".xml")
      doc = REXML::Document.new File.read(path)
      rich_rules = []

      # Loop through the zone elements
      doc.elements.each("zone/*") do |e|
 
        if e.name == 'rule'

            rule_source = {}
            rule_destination = {}
            rule_service = ''
            rule_ports = {}
            rule_protocol = ''
            rule_icmp_blocks = ''
            rule_masquerade = false
            rule_forward_ports = {}
            rule_log = {}
            rule_audit = {}
            rule_action = {}
            rule_family = 'ipv4'

          e.elements.each do |rule|
            if rule.name == 'source'
              rule_source['address'] = rule.attributes["address"]
              if rule.attributes["invert"] == 'true'
                rule_source['invert'] = true
              else
                rule_source['invert'] = rule.attributes["invert"].nil? ? nil : false
              end
              rule_source.delete_if { |key,value| key == 'invert' and value == nil}

            end
            if rule.name == 'destination'
              rule_destination['address'] = rule.attributes["address"]
              if rule.attributes["invert"] == 'true'
                rule_destination['invert'] = true
              else
                rule_destination['invert'] = rule.attributes["invert"].nil? ? nil : false
              end
              rule_destination.delete_if { |key,value| key == 'invert' and value == nil}
            end
            if rule.name == 'service'
              rule_service = rule.attributes["name"]
            end
            if rule.name == 'port'
              rule_ports['portid'] = rule.attributes["port"].nil? ? nil : rule.attributes["port"]
              rule_ports['protocol'] = rule.attributes["protocol"].nil? ? nil : rule.attributes["protocol"]
            end
            if rule.name == 'protocol'
              rule_protocol = rule.attributes["value"]
            end
            if rule.name == 'icmp-block'
              rule_icmp_blocks = rule.attributes["name"]
            end
            if rule.name == 'masquerade'
              rule_masquerade = true
            end
            if rule.name == 'forward-port'
              rule_forward_ports['portid'] = rule.attributes["port"].nil? ? nil : rule.attributes["port"]
              rule_forward_ports['protocol'] = rule.attributes["protocol"].nil? ? nil : rule.attributes["protocol"]
              rule_forward_ports['to_port'] = rule.attributes["to-port"].nil? ? nil : rule.attributes["to-port"]
              rule_forward_ports['to_addr'] = rule.attributes["to-addr"].nil? ? nil : rule.attributes["to-addr"]
            end
            if rule.name == 'log'
              begin
                limit = rule.elements["limit"].attributes["value"]
              rescue
                limit = nil
              end
              rule_log['prefix'] = rule.attributes["prefix"].nil? ? nil : rule.attributes["prefix"]
              rule_log['level'] = rule.attributes["level"].nil? ? nil : rule.attributes["level"]
              rule_log['limit'] = limit
            end
            if rule.name == 'audit'
              rule_audit ['limit'] = rule.elements["limit"].attributes["value"].nil? ? nil : rule.elements["limit"].attributes["value"]
            end
            if rule.name == 'accept'
              begin
                limit = rule.elements["limit"].attributes["value"]
              rescue
                limit = nil
              end
              rule_action['action_type'] = rule.name
              rule_action['reject_type'] = nil
              rule_action['limit'] = limit
            end
            if rule.name == 'reject'
              begin
                limit = rule.elements["limit"].attributes["value"]
              rescue
                limit = nil
              end
              rule_action['action_type'] = rule.name
              rule_action['reject_type'] = rule.attributes["type"].nil? ? nil : rule.attributes["type"]
              rule_action['limit']  = limit
            end
            if rule.name == 'drop'
              begin
                limit = rule.elements["limit"].attributes["value"]
              rescue
                limit = nil
              end
              rule_action['action_type'] = rule.name
              rule_action['reject_type'] = nil
              rule_action['limit']  = limit
            end
            if rule.name == 'family'
              rule_family = rule.attributes["type"].nil? ? nil : rule.attributes["family"]
            end
          end
          rich_rules << {
            'source'        => rule_source.empty? ? nil : rule_source,
            'destination'   => rule_destination.empty? ? nil : rule_destination,
            'service'      => rule_service.empty? ? nil : rule_service,
            'port'          => rule_ports.empty? ? nil : rule_ports,
            'protocol'      => rule_protocol.empty? ? nil : rule_protocol,
            'icmp_block'   => rule_icmp_blocks.empty? ? nil : rule_icmp_blocks,
            'masquerade'    => rule_masquerade.nil? ? nil : rule_masquerade,
            'forward_port' => rule_forward_ports.empty? ? nil : rule_forward_ports,
            'log'         => rule_log.empty? ? nil : rule_log,
            'audit'         => rule_audit.empty? ? nil : rule_audit,
            'action'        => rule_action.empty? ? nil : rule_action,
            'family'        => rule_family.empty? ? nil : rule_family,
           }

           # remove services if not set so the data type matches the data type returned by the puppet resource.
           rich_rules.each { |a| a.delete_if { |key,value| key == 'service' and value == nil} }
           rich_rules.each { |a| a.delete_if { |key,value| key == 'forward_port' and value == nil} }
           rich_rules.each { |a| a.delete_if { |key,value| key == 'protocol' and value == nil} }
           rich_rules.each { |a| a.delete_if { |key,value| key == 'icmp_block' and value == nil} }
           rich_rules.each { |a| a.delete_if { |key,value| key == 'masquerade' and value == false} }
           rich_rules.each { |a| a.delete_if { |key,value| key == 'audit' and value == nil} }
           rich_rules.each { |a| a.delete_if { |key,value| key == 'log' and value == nil} }
           rich_rules.each { |a| a.delete_if { |key,value| key == 'destination' and value == nil} }
           rich_rules.each { |a| a.delete_if { |key,value| key == 'source' and value == nil} }
           rich_rules.each { |a| a.delete_if { |key,value| key == 'port' and value == nil} }
           
           rich_rules.each { |rr| 
             if rr["action"]
               rr["action"].delete_if {|key,value| key == 'limit' and value == nil} 
               rr["action"].delete_if {|key,value| key == 'reject_type' and value == nil} 
             end
             if rr["forward_port"]
               rr["forward_port"].delete_if {|key,value| key == 'to_addr' and value == nil}
             end
           }
        end
      end
      rich_rules
    end
end
