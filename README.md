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
* Install Tomcat 8 and deploy Guacd to him.
* Configure unlimited amount of users with connection list.

### Setup Requirements **OPTIONAL**

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
    guacd_listen_port => '4822'
  }
  # Create an user in Guacamole with available connections as $hashes
  guacamole::user { 'bohdan':
    password    => 'passw0rd',
    connections => $hashes
  }
```

## Reference

For all usage you just need ::guacamole and ::guacamole::user.
Will finish this section later.

## Limitations

By now this module applies only for CentOS7(6 maybe).

## Development

Feel free to fork, pull requests and so on.

## Release Notes/Contributors/Etc.

```
0.1.0:
  - First version of this cute module.
  - Cake is a Lie.
```

## TODO
```
- Implement usage of your own Tomcat instances.
- Add Debian/Ubuntu support
- Add function to determine closest apache mirror.
```
