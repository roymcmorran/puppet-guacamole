# guacamole::build
#
# Build something from source
# @example
#     guacamole::build { '/folder/with/source/':
#        options => '--with-init-dir=/etc/init.d',
#        path    => "/sbin:/bin:/usr/bin:$name"
#      }

define guacamole::build(
  $dir     = $title,
  $user    = 'root',
  $path    = '/sbin:/bin:/usr/sbin:/usr/bin:/opt/puppetlabs/bin',
  $timeout = '0',
  $options = ''
) {

  $options_real = join([$options], ' ')

  Exec {
    user    => $user,
    cwd     => $dir,
    timeout => $timeout,
    path    => $path,
  }

  exec { "./configure in ${dir}":
    command     => "configure ${options_real}",
    subscribe   => Archive['/tmp/gcml/guacamole-server.tar.gz'],
    refreshonly => true,
    notify      => Exec["make in ${dir}"]
  }

  exec { "make in ${dir}":
    command     => 'make',
    refreshonly => true,
    notify      => Exec["make install in ${dir}"]
  }

  exec { "make install in ${dir}":
    command     => 'make install',
    refreshonly => true,
    notify      => Exec['ldconfig']
  }

  exec { 'ldconfig':
    refreshonly => true,
  }

}
