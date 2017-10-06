# guacamole::user
#
# Create the user for Guacamole with connection list.
#
#
# @example
#   guacomole::user { 'username':
#     password    => 'qwerty'
#     connections => {
#    '192.168.1.101' => {       #Hostname or IP address
#      'rdp' => {               # Protocol of connection: rdp,vnc,ssh
#          'password'    => 'vagrant',
#          'username'    => 'vagrant',
#          'port'        => '3389', # default rdp port
#          'security'    => 'nla', #Network Level Authentication
#          'ignore-cert' => 'true'
#          # Watch more here: https://guacamole.incubator.apache.org/doc/gug/configuring-guacamole.html#rdp
#      }
#    }
#  }
#
#   }
define guacamole::user (
  String $password,
  Hash $connections,
  Optional[Boolean] $md5_encrypted = false,
) {

  $username = $name

  concat::fragment { "user-mapping+10_${name}.xml":
    target  => '/etc/guacamole/user-mapping.xml',
    content => template('guacamole/user-mapping.xml.erb'),
    order   => "10-${name}",
  }
}
