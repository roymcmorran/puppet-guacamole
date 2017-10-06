# guacamole::install
#
# Installation of Guacamole & provision
# Considered to be private class.
class guacamole::install (
    String $server_version = '0.9.13',
    String $guacd_listen_ip = '127.0.0.1',
    String $guacd_listen_port = '4822'
  ) {
    $tomcat_version = '8.5.23'
    tomcat::install { '/opt/tomcat':
      source_url => "http://apache.ip-connect.vn.ua/tomcat/tomcat-8/v${tomcat_version}/bin/apache-tomcat-${tomcat_version}.tar.gz",
    }
    tomcat::instance { 'default':
      catalina_home  => '/opt/tomcat',
      #manage_service => true,
    }
  # @TODO: Add function to determine closest mirror
  #$closest_mirror = inline_template(
  #  "<%= `curl -s \'https://www.apache.org/dyn/closer.cgi?as_json=1\' | jq --raw-output \'.preferred|rtrimstr("/")\'` %>"
  #  )
  $closest_mirror = 'http://apache.volia.net'

  file { [ '/etc/guacamole', '/etc/guacamole/extensions', '/etc/guacamole/lib', '/tmp/gcml' ]:
    ensure => directory
  }

  archive { '/tmp/gcml/guacamole-server.tar.gz':
    ensure       => present,
    source       => "${closest_mirror}/incubator/guacamole/${server_version}-incubating/source/guacamole-server-${server_version}-incubating.tar.gz",
    extract      => true,
    creates      => "/tmp/gcml/guacamole-server-${server_version}-incubating/configure",
    cleanup      => true,
    extract_path => '/tmp/gcml/',
    notify       => Guacamole::Build["/tmp/gcml/guacamole-server-${server_version}-incubating"]
    # require => File[$install_path],
  }

  guacamole::build { "/tmp/gcml/guacamole-server-${server_version}-incubating":
    options => '--with-init-dir=/etc/init.d',
    path    => "/sbin:/bin:/usr/bin:/tmp/gcml/guacamole-server-${server_version}-incubating"
  }
  Archive['/tmp/gcml/guacamole-server.tar.gz'] ~> Guacamole::Build["/tmp/gcml/guacamole-server-${server_version}-incubating"] ~> Service['guacd']

  file_line { 'guacamole-home-line':
    path  => '/etc/environment',
    line  => 'GUACAMOLE_HOME=/etc/guacamole/',
    match => 'GUACAMOLE_HOME=',
  }
  service { 'tomcat':
    ensure     => running,
    #provider   => 'init'
    start      => '/opt/tomcat/bin/startup.sh',
    stop       => '/opt/tomcat/bin/shutdown.sh',
    restart    => '/opt/tomcat/bin/shutdown.sh && /opt/tomcat/bin/startup.sh', # genius
    status     => "ps aux | grep 'catalina.base=/opt/tomcat' | grep -v grep",
    hasstatus  => true,
    hasrestart => true,
    #require    => Tomcat::Instance['default'],
    subscribe  => File['/etc/guacamole/guacd.conf']
  }
  tomcat::war { 'guacamole.war':
    catalina_base => '/opt/tomcat',
    war_source    => "${closest_mirror}/incubator/guacamole/${server_version}-incubating/binary/guacamole-${server_version}-incubating.war",
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
