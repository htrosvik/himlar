#
# Author: Yanis Guenane <yguenane@gmail.com>
# License: ApacheV2
#
# Puppet module :
#   mod 'puppetlabs/stdlib'
#   mod 'puppetlabs/concat'
#   mod 'puppetlabs/apache'
#
class profile::webserver::apache (
  $manage_ssl_cert  = false,
  $dev_enable       = false,
  $mods_enable      = [],
  $manage_firewall  = true,
  $firewall_ports   = [80, 443],
  $firewall_extras  = {}
) {

  include ::apache

  if $dev_enable {
    include ::apache::dev
  }

  if !empty($mods_enable) {
    $modules = prefix($mods_enable, '::apache::mod::')
    class { $modules : }
  }

  if $manage_ssl_cert {
    include profile::application::sslcert
    Class['Profile::Application::Sslcert'] ~>
    Class['Apache::Service']
  }

  $vhosts = hiera_hash('profile::webserver::apache::vhosts', {})
  create_resources('::apache::vhost', $vhosts)

  if $manage_firewall {
    profile::firewall::rule { '100 apache accept tcp 80 443':
      port   => $firewall_ports,
      extras => $firewall_extras
    }
  }

}
