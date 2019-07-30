#
# == Class: php::intl
#
# A convenience class to be used for requires and in node definitions
#
class php::intl {
    include ::php
    include ::php::install::intl
}

