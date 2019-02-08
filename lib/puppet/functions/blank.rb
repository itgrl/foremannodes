#
# An object is blank if it’s false, empty, or a whitespace string. For example, false, ”, ‘ ’, nil, [], and {} are all blank.
#
require File.expand_path(File.join(File.dirname(__FILE__),'..','..','puppet/util/blank.rb'))

Puppet::Functions.create_function(:blank) do

#  Puppet::Parser::Functions::Error.is4x('blank')
  def blank(item)
    item.blank?
  end

end

