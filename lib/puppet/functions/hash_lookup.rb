Puppet::Functions.create_function(:hash_lookup) do
  dispatch :hash_lookup do
    param 'Hash', :parameters_hash
    param 'String', :key
  end

  def hash_lookup(parameters_hash = {}, key)
    if parameters_hash.include? key
      parameters_hash[key]
    else
      if key.include? "."
        values=key.split('.')
        value=parameters_hash.dig(values[0],values[1])
        value
      end
    end
  end
end

