# guacamole
#
# Main class for usage of this module.
#
# @summary Executes classes preprovision and install for Guacomole installation.
#
# @param server_version  -   Version of guacamole server to download and install.
#                            You could check the latest one there:
#                            https://guacamole.incubator.apache.org/releases/
# @param guacd_listen_ip   - IP for guacd to bind for.
# @param guacd_listen_port - Same for port.
# @example
#   Full example of usage included in examples/site.pp
class guacamole (
  String $server_version = '0.9.13',
  String $guacd_listen_ip = '127.0.0.1',
  String $guacd_listen_port = '4822'
  ) {
    class { '::guacamole::install':
      server_version    => $server_version,
      guacd_listen_ip   => $guacd_listen_ip,
      guacd_listen_port => $guacd_listen_port
    }
    include guacamole::preprovision
    Class['guacamole::preprovision'] -> Class['guacamole::install']

}
