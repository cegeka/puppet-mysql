define mysql::database($ensure) {

  include  mysql::server

  if $facts['mysql_exists'] {
    mysql_database { $name:
      ensure  => $ensure,
      require => Service[$mysql::params::myservice]
    }
  } else {
    fail("Mysql binary not found, Fact[::mysql_exists]:${facts['mysql_exists']}")
  }

}
