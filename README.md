[![Build Status](https://travis-ci.org/slenky/puppet-guacamole.svg?branch=master)](https://travis-ci.org/slenky/puppet-guacamole)

# Guacamole - Puppet Module

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with guacamole](#setup)
    * [What guacamole affects](#what-guacamole-affects)
    * [Setup requirements](#setup-requirements)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

This module installs, deploys and configures [Apache Guacomole](#https://guacamole.incubator.apache.org/) on CentOS7.

## Setup

### What guacamole affects **OPTIONAL**

* Install Guacamole required packages.
* Build & Deploy guacd
* (OPTIONAL) Install Tomcat 8, deploy guacamole to him.
* Configure unlimited amount of users with connection list.

### Setup Requirements

Just install dependent modules.

## Usage

```
  # Hash of the servers for Guacamole to connect for.
  $hashes = {
    '192.168.1.101' => {             #Hostname or IP address
      'rdp' => {                     # Protocol of connection: rdp,vnc,ssh
          'password'    => 'vagrant',
          'username'    => 'vagrant',
          'port'        => '3389',   # default rdp port
          'security'    => 'nla',    #Network Level Authentication
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
    guacd_listen_port => '4822',
    install_tomcat    => true
  }
  # Create an user in Guacamole with available connections as $hashes
  guacamole::user { 'bohdan':
    password    => 'passw0rd',
    connections => $hashes
  }
```

## Reference

For all usage you just need ::guacamole and ::guacamole::user.
#### guacamole
The base class sets defaults used by other defined types, such as `guacamole::install`.

##### `guacd_listen_ip`
Specifies an IP for guacd to bind for. Basically, should be localhost, so you could omit this option.
##### `guacd_listen_port`
Same as above.
##### `server_version`
Specifies the version of Guacamole to build & install. Default to '0.9.13' but you could always change it to newer version from [here](https://guacamole.incubator.apache.org/releases/)
##### `install_tomcat`
Boolean. Specifies should this module install Tomcat 8 for you. Defaults to true. If you want to use your own installation of Tomcat you have to add something like this one to your modules:
```
$closest_mirror = get_mirrors('https://www.apache.org/dyn/closer.cgi?as_json=1')
tomcat::war { 'guacamole.war':
  catalina_base => '/opt/tomcat',
  war_source    => "${closest_mirror}incubator/guacamole/${server_version}-incubating/binary/guacamole-${server_version}-incubating.war",
}
```
#### guacamole::user
Defined class that being used for creation of users and connections for them. Might be initiated as more as you need it.
##### Title
Title of the resource applies to username for new/exist user.
```
guacamole::user { 'username'
  ...
}
```
##### `password`
Plain text password for user (might also be md5 encrypted with md5_encrypted variable)
##### `md5_encrypted`
Boolean. Sets password format as md5. Feel free to use [this](http://www.md5online.org/md5-encrypt.html)
## Limitations

By now this module applies only for CentOS7 (and probably 6 version too).

## Development

Feel free to fork, pull requests and so on.

## Release Notes/Contributors/Etc.
```
0.2.0:
  - Added install_tomcat variable to use your own instances.
  - Added determining of closest mirror to download tomcat / guacamole.
  - Few small fixes.
```
```
0.1.0:
  - First version of this cute module.
  - Cake is a Lie.
```

## TODO
```
- Add Debian/Ubuntu support
- Implement md5 encryption from plain text.
```
