require 'puppet'
require 'puppet/provider/firewalld'
require 'rexml/document'
include REXML

Puppet::Type.type(:firewalld_zone).provide :zoneprovider, :parent => Puppet::Provider::Firewalld do
    @doc = "The zone config manipulator"

    commands :firewall => 'firewall-cmd'

    mk_resource_methods
 
    def flush
        Puppet.debug "firewalld zone provider: flushing (@resource[:name])"
	write_zonefile
    end

    def create
        Puppet.debug "firewalld zone provider: create (@resource[:name])"
	write_zonefile
    end

    def write_zonefile
        Puppet.debug "firewalld zone provider: write_zonefile (@resource[:name])"
        doc = REXML::Document.new
        zone = doc.add_element 'zone'
        doc << REXML::XMLDecl.new(version='1.0',encoding='utf-8')

        if @resource[:target]
          zone.add_attribute('target', @resource[:target])
        end

        if @resource[:short]
          short = zone.add_element 'short'
          short.text = @resource[:short]
        end

        if @resource[:description]
          description = zone.add_element 'description'
          description.text = @resource[:description]
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
            Puppet.debug "firewalld zone provider: adding service (#{service}) to zone"
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

        if @resource[:masquerade].at(0).to_s == 'true'
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
        Puppet.debug "firewalld zone provider: Changes to #{path} configuration saved to disk."
        firewall('--reload')
        Puppet.debug "firewalld zone provider: reloading firewalld configuration"
    end

  def self.instances
    debug "[instances]"
    zonefiles = Dir["/etc/firewalld/zones/*.xml"]

    zone = []

    zonefiles.each do |path|
      zonename = File.basename(path, ".xml")
      doc = REXML::Document.new File.read(path)
      target = ''
      version = ''
      short = ''
      description = ''
      interface = []
      source = []
      service = []
      ports = []
      icmp_blocks = []
      masquerade = false
      forward_ports = []
      rich_rules = []

      # Set zone level variables
      root = doc.root
      target = root.attributes["target"]
      version = root.attributes["version"]

      # Loop through the zone elements
      doc.elements.each("zone/*") do |e|

        if e.name == 'short'
          short = e.text.to_s.strip
        end
        if e.name == 'description'
          description = e.text.to_s.strip
        end
        if e.name == 'interface'
          interface << e.attributes["name"]
        end
        if e.name == 'source'
          source << e.attributes["address"]
        end
        if e.name == 'service'
          service << e.attributes["name"]
        end
        if e.name == 'port'
          ports << {
            'port' => e.attributes["port"].nil? ? nil : e.attributes["port"],
            'protocol' => e.attributes["protocol"].nil? ? nil : e.attributes["protocol"],
          }
        end
        if e.name == 'icmp-block'
          icmp_blocks << e.attributes["name"]
        end
        if e.name == 'masquerade'
          masquerade = true
        end
        if e.name == 'forward-port'
          forward_ports << {
            'port' => e.attributes["port"].nil? ? nil : e.attributes["port"],
            'protocol' => e.attributes["protocol"].nil? ? nil : e.attributes["protocol"],
            'to-port' => e.attributes["to-port"].nil? ? nil : e.attributes["to-port"],
            'to-addr' => e.attributes["to-addr"].nil? ? nil : e.attributes["to-addr"],
          }
        end

        if e.name == 'rule'

            rule_source = []
            rule_destination = []
            rule_service = []
            rule_ports = []
            rule_protocol = []
            rule_icmp_blocks = []
            rule_masquerade = false
            rule_forward_ports = []
            rule_log = []
            rule_audit = []
            rule_action = []

          e.elements.each do |rule|
            if rule.name == 'source'
              rule_source << rule.attributes["address"]
            end
            if rule.name == 'destination'
              rule_destination << rule.attributes["address"]
            end
            if rule.name == 'service'
              rule_service << rule.attributes["name"]
            end
            if rule.name == 'port'
              rule_ports << {
                'port' => rule.attributes["port"].nil? ? nil : rule.attributes["port"],
                'protocol' => rule.attributes["protocol"].nil? ? nil : rule.attributes["protocol"],
              }
            end
            if rule.name == 'protocol'
              rule_protocol << rule.attributes["value"]
            end
            if rule.name == 'icmp-block'
              rule_icmp_blocks << rule.attributes["name"]
            end
            if rule.name == 'masquerade'
              rule_masquerade = true
            end
            if rule.name == 'forward-port'
              rule_forward_ports << {
                'port' => rule.attributes["port"].nil? ? nil : rule.attributes["port"],
                'protocol' => rule.attributes["protocol"].nil? ? nil : rule.attributes["protocol"],
                'to-port' => rule.attributes["to-port"].nil? ? nil : rule.attributes["to-port"],
                'to-addr' => rule.attributes["to-addr"].nil? ? nil : rule.attributes["to-addr"],
              }
            end
            if rule.name == 'log'
              begin
                limit = rule.elements["limit"].attributes["value"]
              rescue
                limit = nil
              end
              rule_log << {
                'prefix' => rule.attributes["prefix"].nil? ? nil : rule.attributes["prefix"],
                'level' => rule.attributes["level"].nil? ? nil : rule.attributes["level"],
                'level' => rule.attributes["level"].nil? ? nil : rule.attributes["level"],
                'limit' => limit,
              }
            end
            if rule.name == 'audit'
              rule_audit << {
                 'limit'  => rule.elements["limit"].attributes["value"].nil? ? nil : rule.elements["limit"].attributes["value"],
              }
            end
            if rule.name == 'accept'
              begin
                limit = rule.elements["limit"].attributes["value"]
              rescue
                limit = nil
              end
              rule_action << {
                'action_type' => rule.name,
                'reject_type' => nil,
                'limit' => limit,
              }
            end
            if rule.name == 'reject'
              begin
                limit = rule.elements["limit"].attributes["value"]
              rescue
                limit = nil
              end
              rule_action << {
                'action_type' => rule.name,
                'reject_type' => rule.attributes["type"].nil? ? nil : rule.attributes["type"],
                'limit'  => limit,
              }
            end
            if rule.name == 'drop'
              begin
                limit = rule.elements["limit"].attributes["value"]
              rescue
                limit = nil
              end
              rule_action << {
                'action_type' => rule.name,
                'reject_type' => nil,
                'limit'  => limit,
              }
            end
          end
          rich_rules << {
            :sources       => rule_source.empty? ? nil : rule_source,
            :destination   => rule_destination.empty? ? nil : rule_destination,
            :services      => rule_service.empty? ? nil : rule_service,
            :ports         => rule_ports.empty? ? nil : rule_ports,
            :protocol      => rule_protocol.empty? ? nil : rule_protocol,
            :icmp_blocks   => rule_icmp_blocks.empty? ? nil : rule_icmp_blocks,
            :masquerade    => rule_masquerade.nil? ? nil : rule_masquerade,
            :forward_ports => rule_forward_ports.empty? ? nil : rule_forward_ports,
            :log           => rule_log.empty? ? nil : rule_log,
            :audit         => rule_audit.empty? ? nil : rule_audit,
            :action        => rule_action.empty? ? nil : rule_action,
           }

        end

      end

      # Add hash to the zone array
      zone << new({
        :name          => zonename,
        :ensure        => :present,
        :target        => target.nil? ? nil : target,
        :version       => version.nil? ? nil : version,
        :short         => short.nil? ? nil : short,
        :description   => description.nil? ? nil : description,
        :interfaces    => interface.empty? ? nil : interface,
        :sources       => source.empty? ? nil : source,
        :services      => service.empty? ? nil : service,
        :ports         => ports.empty? ? nil : ports,
        :icmp_blocks   => icmp_blocks.empty? ? nil : icmp_blocks,
        :masquerade    => masquerade.nil? ? nil : masquerade,
        :forward_ports => forward_ports.empty? ? nil : forward_ports,
        :rich_rules    => rich_rules.empty? ? nil : rich_rules,
      })
    end
    zone
  end
 
    def destroy
        path = '/etc/firewalld/zones' + @resource[:name] + '.xml'
        File.delete(path)
        Puppet.debug "firewalld zone provider: removing (#{path})"
        @property_hash.clear
    end
 
    def exists?
        @property_hash[:ensure] == :present || false
    end
end
