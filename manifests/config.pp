#
#
#== Definition: mysql::config
#
#Set mysql configuration parameters
#
#Parameters:
#- *value*: the value to be set, defaults to the empty string;
#- *key*: optionally, set the key (defaults to $name);
#- *ensure*: defaults to present.
#
#Example usage:
#  mysql::config {'mysqld/pid-file':
#    ensure => present,
#    value => '/var/run/mysqld/mysqld.pid',
#  }
#
#If the section (e.g. 'mysqld/') is ommitted in the resource name,
#it defaults to 'mysqld/'.
#

define mysql::config (
  $ensure='present',
  $key='',
  $value='',
) {

  $real_name = $key ? {
    ''      => $name,
    default => $key,
  }

  $real_key = inline_template('<%= @real_name.split(\'/\')[-1] %>')

  $section = inline_template('<%= if @real_name.split(\'/\')[-2]
@real_name.split(\'/\')[-2]
else
\'mysqld\'
end %>')

  case $ensure {
    present: {
      $changes = "set ${real_key} ${value}"
    }

    absent: {
      $changes = "rm ${real_key}"
    }

    default: { err ( "unknown ensure value ${ensure}" ) }
}

augeas { "${mysql::params::mycnfctx}/${section}/${name}":
  context => "${mysql::params::mycnfctx}/target[.='${section}']",
  changes => [
    "set ${mysql::params::mycnfctx}/target[.='${section}'] ${section}",
    $changes,
    "rm ${mysql::params::mycnfctx}/target[count(*)=0]",
  ],
  require => [ File[ $mysql::params::mycnf ], File[ $mysql::params::real_data_dir ] ],
  notify  => Service[ $mysql::params::myservice ],
  }
}
