# guacamole::install
#
# Installation of Guacamole & provision
# Considered to be private class.
class guacamole::install (
    String $server_version = '0.9.13',
    String $guacd_listen_ip = '127.0.0.1',
    String $guacd_listen_port = '4822',
    Boolean $install_tomcat = true,
  ) {
    $tomcat_version = '8.5.23'
    $closest_mirror = get_mirrors('https://www.apache.org/dyn/closer.cgi?as_json=1')

    if $install_tomcat {
      tomcat::install { '/opt/tomcat':
        source_url => "${closest_mirror}tomcat/tomcat-8/v${tomcat_version}/bin/apache-tomcat-${tomcat_version}.tar.gz",
      }
      tomcat::instance { 'default':
        catalina_home  => '/opt/tomcat',
        #manage_service => true,
      }
      service { 'tomcat':
        ensure     => running,
        start      => '/opt/tomcat/bin/startup.sh',
        stop       => '/opt/tomcat/bin/shutdown.sh',
        restart    => '/opt/tomcat/bin/shutdown.sh && /opt/tomcat/bin/startup.sh', # genius
        status     => "ps aux | grep 'catalina.base=/opt/tomcat' | grep -v grep",
        hasstatus  => true,
        hasrestart => true,
        #require    => Tomcat::Instance['default'],
        #subscribe  => File['/etc/guacamole/guacd.conf']
      }
      File['/etc/guacamole/guacd.conf'] ~> Service['tomcat']
      tomcat::war { 'guacamole.war':
        catalina_base => '/opt/tomcat',
        war_source    => "${closest_mirror}guacamole/${server_version}/binary/guacamole-${server_version}.war",
      }
    }


  file { [ '/etc/guacamole', '/etc/guacamole/extensions', '/etc/guacamole/lib', '/tmp/gcml' ]:
    ensure => directory
  }

  archive { '/tmp/gcml/guacamole-server.tar.gz':
    ensure       => present,
    source       => "${closest_mirror}guacamole/${server_version}/source/guacamole-server-${server_version}.tar.gz",
    extract      => true,
    creates      => "/tmp/gcml/guacamole-server-${server_version}/configure",
    cleanup      => true,
    extract_path => '/tmp/gcml/',
    notify       => Guacamole::Build["/tmp/gcml/guacamole-server-${server_version}"]
    # require => File[$install_path],
  }

  guacamole::build { "/tmp/gcml/guacamole-server-${server_version}":
    options => '--with-init-dir=/etc/init.d',
    path    => "/sbin:/bin:/usr/bin:/tmp/gcml/guacamole-server-${server_version}"
  }
  Archive['/tmp/gcml/guacamole-server.tar.gz'] ~> Guacamole::Build["/tmp/gcml/guacamole-server-${server_version}"] ~> Service['guacd']

  file_line { 'guacamole-home-line':
    path  => '/etc/environment',
    line  => 'GUACAMOLE_HOME=/etc/guacamole/',
    match => 'GUACAMOLE_HOME=',
  }

  file { '/etc/guacamole/guacd.conf':
    ensure  => file,
    content => template('guacamole/guacd.conf.erb'),
    notify  => Service['guacd'],
  }
  file { '/etc/guacamole/guacamole.properties':
    ensure  => file,
    owner   => 'tomcat',
    group   => 'tomcat',
    content => template('guacamole/guacamole.properties.erb'),
  }

  service { 'guacd':
    ensure => running,
    enable => true,
  }

  concat::fragment { 'user-mapping+start.xml':
    target  => '/etc/guacamole/user-mapping.xml',
    content => '<user-mapping>',
    order   => '01'
  }
  concat::fragment { 'user-mapping+end.xml':
    target  => '/etc/guacamole/user-mapping.xml',
    content => '</user-mapping>',
    order   => '990'
  }
  concat { '/etc/guacamole/user-mapping.xml':
    ensure => present,
  }
}
