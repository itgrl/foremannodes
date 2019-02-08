#
# An object is blank if it’s false, empty, or a whitespace string. For example, false, ”, ‘ ’, nil, [], and {} are all blank.
#
  class NilClass
    def blank?
      true
    end
  end

  class FalseClass
    def blank?
      true
    end
  end

  class TrueClass
    def blank?
      false
    end
  end

  class Object
    def blank?
      respond_to?(:empty?) ? empty? : !self
    end
  end

  class String
    # 0x3000: fullwidth whitespace
    NON_WHITESPACE_REGEXP = %r![^\s#{[0x3000].pack("U")}]!

    # A string is blank if it's empty or contains whitespaces only:
    #
    #   "".blank?                 # => true
    #   "   ".blank?              # => true
    #   "".blank?               # => true
    #   " something here ".blank? # => false
    #
    def blank?
      self !~ NON_WHITESPACE_REGEXP
    end
  end
