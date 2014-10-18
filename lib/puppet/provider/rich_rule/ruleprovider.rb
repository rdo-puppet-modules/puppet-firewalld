require 'puppet'
require 'rexml/document'
include REXML

Puppet::Type.type(:rich_rule).provide :ruleprovider do
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
end
