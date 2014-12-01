class Puppet::Provider::Firewalld < Puppet::Provider

  # Prefetch xml data.
  def self.prefetch(resources)
    debug("[prefetch(resources)]")
    Puppet.debug "firewalld prefetch instance: #{instances}"
    instances.each do |prov|
      Puppet.debug "firewalld prefetch instance resource: (#{prov.name})"
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  # Clear out the cached values.
  def flush
    @property_hash.clear
  end

  # This allows us to conventiently look up existing status with properties[:foo].
  def properties
    if @property_hash.empty?
      @property_hash[:ensure] = :absent
    end
    @property_hash.dup
  end

end
