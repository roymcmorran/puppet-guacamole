# guacamole::preprovision
#
# Requirements installation for Guacomole building & usage
#
# Considered to be private class.
class guacamole::preprovision inherits guacamole::install {
  $packages = [
  'cairo-devel', 'libjpeg-turbo-devel', 'libpng-devel', 'uuid-devel',
  'ffmpeg-devel', 'freerdp-devel', 'pango-devel', 'libssh2-devel',
  'libtelnet-devel', 'libvncserver-devel', 'pulseaudio-libs-devel',
  'openssl-devel', 'libvorbis-devel', 'libwebp-devel', 'jq'
  ]


  package { 'epel-release':
    ensure   => present,
    provider => yum
  }
  package { 'rest-client':
    ensure   => present,
    provider => gem
  }
  package { 'nux-dextop-release':
    ensure   => present,
    provider => 'rpm',
    require  => Package['epel-release'],
    source   => 'http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm',
  }

  exec { '/bin/yum update -y':
    refreshonly => true,
    subscribe   => Package['nux-dextop-release']
  }

  package { $packages: ensure => present }
  class { 'java': }

}
