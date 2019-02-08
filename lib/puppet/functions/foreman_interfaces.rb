require File.expand_path(File.join(File.dirname(__FILE__),'..','..','puppet/util/blank.rb'))

Puppet::Functions.create_function(:foreman_interfaces) do
  # Function to prepare data hashes for interfaces based on the type provided.
  # Valid types are: static, dynamic, bond, bridge, or interface
  # If type is not provided, then interface without IP is managed.
  local_types do
    type 'IntType = Enum[static_if, dynamic_if, static_bond, dynamic_bond, static_bridge, dynamic_bridge, slave, virtual_if]'
  end

  dispatch :init do
    optional_param 'IntType', :inttype
  end

  dispatch :convert_data do
    param 'IntType', :interface_type         # Interface type to prepare the data for.
    param 'Boolean', :managed_only           # Set to true if only to include managed interfaces.
    param 'String', :subnet_match_key        # The key used to match subnets, such as 'subnet.name'
    param 'String', :interface_type_key      # The key used to match interfaces, such as 'type'
    param 'Hash', :value_map                 # Value map
    param 'String', :boot_mode               # Boot mode to match against, 'Static or DHCP'
    optional_param 'String', :subnet_match      # Only prepare data for listed subnets
    optional_param 'Array', :optional_values # Optional values to include
  end


  def init(inttype)
    # Set default variable values.  Can be overridden later per function call and call type.
    interface_type=""
    subnet_match=""
    managed_only=true
    subnet_match_key='subnet.name'
    interface_type_key='type'
    value_map=''
    optional_values=''
    boot_mode=''
    default_value_map = {
      'title'      => 'identifier',
      'ipaddress'  => 'ip',
      'netmask'    => ['attrs.netmask', 'subnet.mask'],
      'gateway'    => 'subnet.gateway',
      'dns1'       => 'subnet.dns_primary',
      'dns2'       => 'subnet.dns_secondary',
      'mtu'        => 'attrs.mtu',
      'macaddress' => 'mac',
      'defroute'   => 'primary',
    }
    default_optional_values = [
      'gateway',
      'dns1',
      'dns2',
      'mtu',
      'macaddress',
    ]
    case inttype
    when 'static_if'
      interface_type='interface'
      boot_mode='static'
      if value_map.blank?
        value_map = default_value_map
      end
      if optional_values.blank?
        optional_values = default_optional_values
      end
      if value_map.blank?
        raise Puppet::ParseError, "foreman_interfaces(): value_map is blank."
      end
      convert_data(interface_type, subnet_match, managed_only, subnet_match_key, interface_type_key, value_map, optional_values, boot_mode)
    when 'dynamic_if'
      value_map = {
        'title'      => 'identifier',
        'macaddress' => 'mac',
        'mtu'        => 'attrs.mtu',
        'defroute'   => 'primary',
      }
      optional_values = [
        'mtu',
        'macaddress',
      ]
      interface_type='interface'
      boot_mode='dhcp'
      if value_map.blank?
        value_map = default_value_map
      end
      if optional_values.blank?
        optional_values = default_optional_values
      end
      convert_data(interface_type, subnet_match, managed_only, subnet_match_key, interface_type_key, value_map, optional_values, boot_mode)
    when 'static_bond'
      value_map = {
        'title'        => 'identifier',
        'ipaddress'    => 'ip',
        'netmask'      => ['attrs.netmask', 'subnet.mask'],
        'gateway'      => 'subnet.gateway',
        'dns1'         => 'subnet.dns_primary',
        'dns2'         => 'subnet.dns_secondary',
        'mtu'          => 'attrs.mtu',
        'bond_mode'    => 'mode',
        'bond_options' => 'bond_options',
        'defroute'     => 'primary',
      }
      optional_values = [
        'gateway',
        'dns1',
        'dns2',
        'mtu',
        'bridge',
      ]
      interface_type='bond'
      boot_mode='static'
      if value_map.blank?
        value_map = default_value_map
      end
      if optional_values.blank?
        optional_values = default_optional_values
      end
      convert_data(interface_type, subnet_match, managed_only, subnet_match_key, interface_type_key, value_map, optional_values, boot_mode)
    when 'dynamic_bond'
      value_map = {
        'title'        => 'identifier',
        'mtu'          => 'attrs.mtu',
        'bond_mode'    => 'mode',
        'bond_options' => 'bond_options',
        'defroute'     => 'primary',
      }
      optional_values = [
        'mtu',
        'bridge',
      ]
      interface_type='bond'
      boot_mode='dhcp'
      if value_map.blank?
        value_map = default_value_map
      end
      if optional_values.blank?
        optional_values = default_optional_values
      end
      convert_data(interface_type, subnet_match, managed_only, subnet_match_key, interface_type_key, value_map, optional_values, boot_mode)
    when 'static_bridge'
      interface_type='bridge'
      boot_mode='static'
      if value_map.blank?
        value_map = default_value_map
      end
      if optional_values.blank?
        optional_values = default_optional_values
      end
      convert_data(interface_type, subnet_match, managed_only, subnet_match_key, interface_type_key, value_map, optional_values, boot_mode)
    when 'interface'
      interface_type='interface'
      boot_mode=''  # Need to evaluate this for bonds nics
      if value_map.blank?
        value_map = default_value_map
      end
      if optional_values.blank?
        optional_values = default_optional_values
      end
      convert_data(interface_type, subnet_match, managed_only, subnet_match_key, interface_type_key, value_map, optional_values, boot_mode)
    when 'slave'
      interface_type='slave'
      boot_mode='slave'
      if value_map.blank?
        value_map = default_value_map
      end
      if optional_values.blank?
        optional_values = default_optional_values
      end
      convert_data(interface_type, subnet_match, managed_only, subnet_match_key, interface_type_key, value_map, optional_values, boot_mode)
    when 'virtual_if'
      interface_type='virtual'
      boot_mode='static'
      if value_map.blank?
        value_map = default_value_map
      end
      if optional_values.blank?
        optional_values = default_optional_values
      end
      convert_data(interface_type, subnet_match, managed_only, subnet_match_key, interface_type_key, value_map, optional_values, boot_mode)

    else
      raise Puppet::ParseError, "foreman_interfaces(): You must specify one of the following when calling this function:
        static_if - For static IP interfaces
        dynamic_if - For dynamic IP interfaces
        static_bond - For static IP Bonded interfaces
        dynamic_bond - For dynamic IP Bonded interfaces
        static_bridge - For static IP Bridged interfaces
        dynamic_bridge - For dynamic IP Bridged interfaces
        slave - For Bonded interfaces attached devices
        virtual_if - For Virtual NICs / Secondary IPs on interfaces Bonds or NICs
      "
    end
  end

  def convert_data(interface_type, subnet_match, managed_only, subnet_match_key, interface_type_key, value_map, optional_values, boot_mode)

    # Validate argument types
    unless interface_type.is_a?(String)
      raise Puppet::ParseError, "foreman_interfaces(): unexpected argument type #{interface_type.class}, interface type argument must be a string"
    end
    unless subnet_match.is_a?(String)
      raise Puppet::ParseError, "foreman_interfaces(): unexpected argument type #{subnet_match.class}, subnet_match argument must be a string"
    end
    unless !!managed_only == managed_only || managed_only !~ /^(true|false)$/
      raise Puppet::ParseError, "foreman_interfaces(): unexpected argument type #{managed_only.class}, managed only argument must be true or false"
    end
    unless subnet_match_key.is_a?(String)
      raise Puppet::ParseError, "foremanc_interfaces(): unexpected argument type #{subnet_match_key.class}, subnet key argument must be a string"
    end
    unless interface_type_key.is_a?(String)
      raise Puppet::ParseError, "foreman_interfaces(): unexpected argument type #{interface_type_key.class}, interface type key argument must be a string"
    end
    unless value_map.is_a?(Hash)
      raise Puppet::ParseError, "foreman_interfaces(): unexpected argument type #{value_map.class}, value map argument must be a hash"
    end
    unless optional_values.is_a?(Array)
      raise Puppet::ParseError, "foreman_interfaces(): unexpected argument type #{optional_values.class}, optional values argument must be an array"
    end
    unless boot_mode.is_a?(String)
      raise Puppet::ParseError, "foreman_interfaces(): unexpected argument type #{boot_mode.class}, boot mode argument must be a string"
    end

    scope = closure_scope
    data = scope['foreman_interfaces']

    return {} if data.blank? || data == :undef || data == :undefined

    # Get Array of slave nics
    if boot_mode == 'slave'
      mynics = {}
      mynics = get_slave_nics(interface_type, managed_only, interface_type_key, value_map, optional_values, boot_mode)
      slave = true

    end

    interfaces = {}
    data.each do |d|

      interface = {}
      title = call_function('hash_lookup', d, value_map['title'])
      if slave == true
        if mynics.has_key?(title)
          mynics.each_pair do |key, value|
            next unless key == title
            interface['master'] = value
          end
        else
          next
        end
      else
        if interface_type.downcase == 'virtual'
          next unless  call_function('hash_lookup', d, 'virtual').to_s == 'true'
          next unless  call_function('hash_lookup', d, interface_type_key) == 'Interface'
        else
          # Only deal with Interface types
          next unless  call_function('hash_lookup', d, interface_type_key).downcase == interface_type
        end
        # Only deal with managed interfaces
        if managed_only.to_s == 'true'
          next unless call_function('hash_lookup', d, 'managed').to_s == 'true'
        end
        # If a subnet match was defined, skip if subnet name does not match
        unless subnet_match.blank?
          subnet_name = call_function('hash_lookup', d, subnet_match_key)
          next unless subnet_name == subnet_match
        end
        # Only deal with defined interface boot_mode
        test = d.dig('subnet','boot_mode')
        if test.blank?
          next
        else
          next unless test.downcase == boot_mode.downcase
        end
      end

      value_map.each_pair do |key, map|
        value = nil
        next if key == 'title'
        # Get value based on value map hash
        if map.is_a?(Array)
          map.each do |m|
            value = call_function('hash_lookup', d, m)
            unless value.blank?
              break
            end
          end
        else
          value = call_function('hash_lookup', d, map)
        end
        # Handle optional values which may not be present
        if optional_values.include?(key)
          if value.blank?
            next
          end
        end
        # Check for interface with bond options.  Will use them later
        if interface_type.downcase == 'bond'
          next if key == 'bond_mode'
          next if key == 'bond_options'
        end
        interface[key] = value
      end
      if interface_type.downcase == 'bond'
        interface['bonding_opts']="mode=#{call_function('hash_lookup', d, value_map['bond_mode'])} #{call_function('hash_lookup', d, value_map['bond_options'])}"
      end
      interfaces[title] = interface
    end
    interfaces

  end

  def get_slave_nics(interface_type, managed_only, interface_type_key, value_map, optional_values, boot_mode)

    # Validate argument types
    unless !!managed_only == managed_only || managed_only !~ /^(true|false)$/
      raise Puppet::ParseError, "foreman_interfaces(): unexpected argument type #{managed_only.class}, managed only argument must be true or false"
    end
    unless interface_type_key.is_a?(String)
      raise Puppet::ParseError, "foreman_interfaces(): unexpected argument type #{interface_type_key.class}, interface type key argument must be a string"
    end
    unless value_map.is_a?(Hash)
      raise Puppet::ParseError, "foreman_interfaces(): unexpected argument type #{value_map.class}, value map argument must be a hash"
    end
    unless optional_values.is_a?(Array)
      raise Puppet::ParseError, "foreman_interfaces(): unexpected argument type #{optional_values.class}, optional values argument must be an array"
    end

    scope = closure_scope
    data = scope['foreman_interfaces']

    return [] if data.blank? || data == :undef || data == :undefined

    interfaces = {}
    data.each do |d|

      # Only deal with Bond Interface types
      next unless  call_function('hash_lookup', d, interface_type_key).downcase == 'bond'
      # Only deal with managed interfaces
      if managed_only.to_s == 'true'
        next unless call_function('hash_lookup', d, 'managed').to_s == 'true'
      end
      mynics=call_function('hash_lookup', d, 'attached_devices')
      next if mynics.blank?

      #
      mymaster = call_function('hash_lookup', d, value_map['title'])
      interface = {}
      mynics.split(',').each do |i|
        mynic = i.strip
        interfaces[mynic] = mymaster
      end

    end
    interfaces
  end

end
