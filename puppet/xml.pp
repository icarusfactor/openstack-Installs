#
# == Class: php::xml
#
# A convenience class to be used for requires and in node definitions
#
class php::xml {
    include ::php
    include ::php::install::xml
}
