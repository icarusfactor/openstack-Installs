class { 'apache':}

include ::apache::mod::php
apache::listen { '8080': }

service { 'apache2':
  ensure => running,
  enable => true,
}

