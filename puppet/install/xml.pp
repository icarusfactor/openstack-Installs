#
# == Class: php::install::xml
#
# Install php xml bindings
#
class php::install::xml {

    include ::php::params

    package { 'php-xml':
        ensure  => installed,
        name    => $::php::params::php_xml_package_name,
        require => Class['php::install'],
    }
}

