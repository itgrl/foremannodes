# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include foremannodes
class foremannodes (
  $foreman_subnets                        = $::foreman_subnets,
  $foreman_interfaces                     = $::foreman_interfaces,
  $domainname                             = $::domainname,
  $foreman_domain_description             = $::foreman_domain_description,
  $owner_name                             = $::owner_name,
  $owner_email                            = $::owner_email,
  $foreman_config_groups                  = $::foreman_config_groups,
  $foreman_env                            = $::foreman_env,
  $remote_execution_create_user           = $::remote_execution_create_user,
  $remote_execution_effective_user_method = $::remote_execution_effective_user_method,
  $remote_execution_ssh_user              = $::remote_execution_ssh_user,
  $remote_execution_ssh_user_uid          = '499',
  $remote_execution_ssh_keys              = $::remote_execution_ssh_keys,
  $manage_remote_execution_user_sudo_rule = true,

){

  ## Manage Remote Execution
  ### Only available for *nix at this time
  if $::osfamily != 'Windows' {
    if $remote_execution_create_user.is_a(Boolean) and $remote_execution_create_user {
      user { $remote_execution_ssh_user:
        ensure         => present,
        managehome     => true,
        shell          => '/sbin/nologin',
        comment        => 'Foreman remote execution user',
        uid            => $remote_execution_ssh_user_uid,
        home           => "/home/${remote_execution_ssh_user}",
        password       => '!!',
        purge_ssh_keys => true,
      }

      ## Run Lambda over each item in list
      if $remote_execution_ssh_keys.is_a(Array) {
        $remote_execution_ssh_keys.each | String $key | {
          $keyvalues = split($key, ' ')

          ssh_authorized_key { 'foreman-proxy':
            ensure => present,
            user   => $remote_execution_ssh_user,
            type   => $keyvalues[0],
            key    => $keyvalues[1],
          }
        }
      }
    }
  }

  ## Ensure the sudo rule is set, if enabled
  if $remote_execution_effective_user_method.is_a(String) and ($remote_execution_effective_user_method == 'sudo')  {
    if $manage_remote_execution_user_sudo_rule {
      include sudo
      sudo::conf { 'svcforemanssh':
        ensure         => 'present',
        content        => "svcforemanssh ALL = (root) NOPASSWD : ALL \nDefaults:svcforemanssh !requiretty",
        sudo_file_name => 'foreman-proxy',
      }
    }
  }

  if $foreman_interfaces != undef { include foremannodes::network }

}
