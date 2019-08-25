class { 'apache':
        default_vhost => true,
}

apache::vhost { 'proxy':
  port    => '8080',
  servername => 'proxy',
  docroot => '/var/www/',
}

include ::apache::mod::php
apache::listen { '8080': }

