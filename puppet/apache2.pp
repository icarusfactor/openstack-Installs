class { 'apache':}

include ::apache::mod::php
apache::listen { '8080': }

