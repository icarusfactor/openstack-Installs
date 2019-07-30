#
# == Class: php::install::intl
#
# Install php intl bindings
#
class php::install::intl {

    include ::php::params

    package { 'php-intl':
        ensure  => installed,
        name    => $::php::params::php_intl_package_name,
        require => Class['php::install'],
    }
}
