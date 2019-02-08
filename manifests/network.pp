# This class creates and manages network interfaces as defined in Foreman.
#
# Developed against Foreman 1.17
#
# Assumptions:
#   Foreman is operational and being used as an ENC
#   puppetlabs/stdlib validation functions are used.
#   razorsedge/network module is used
#   razorsedge/network module performs parameter validation
#
# Limitations:
#   IPv4 only at this time.
#   Bridges not managed at this time.
#   Routing is not managed by this module at this time.
#
# To use this class, simply include it.
#   include foremannodes::network
class foremannodes::network {

  $mystatic_if = foreman_interfaces(static_if)
  $mydynamic_if = foreman_interfaces(dynamic_if)
  $mystatic_bond = foreman_interfaces(static_bond)
  $mydynamic_bond = foreman_interfaces(dynamic_bond)
  $myslave_if = foreman_interfaces(slave)
  $myvirtual_if = foreman_interfaces(virtual_if)

  $inttypes = {
    'network::if::static' => $mystatic_if,
    'network::if::dynamic' => $mydynamic_if,
    'network::bond::slave' => $myslave_if,
    'network::bond::static' => $mystatic_bond,
    'network::bond::dynamic' => $mydynamic_bond,
  }


  $inttypes.each | $key, $values | {
    unless $values.blank {
      $defaults = {
        ensure => 'up',
      }
      create_resources($key, $values, $defaults)
    }
  }

}
