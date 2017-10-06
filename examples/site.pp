node 'gserver' {
  # Hash of the servers for Guacamole to connect for. 
  # For Hiera example please look in hieradata folder.
  $hashes = {
    '192.168.1.101' => {       #Hostname or IP address
      'rdp' => {               # Protocol of connection: rdp,vnc,ssh
          'password'    => 'vagrant',
          'username'    => 'vagrant',
          'port'        => '3389', # default rdp port
          'security'    => 'nla', #Network Level Authentication
          'ignore-cert' => 'true'
          # Watch more here: https://guacamole.incubator.apache.org/doc/gug/configuring-guacamole.html#rdp
      }
    },
    '192.168.1.102' => {
      'vnc' => {
          'password' => 'somepass',
          'port' => '5900'
      },
    },
  }
  class { 'guacamole':
    guacd_listen_port => '4822'
  }
  # Create an user in Guacamole with available connections as $hashes
  guacamole::user { 'bohdan':
    password    => 'passw0rd',
    connections => $hashes
  }
  lookup('classes', {merge => unique}).include
}
