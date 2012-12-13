define mysql::database($ensure) {

  include  mysql::server

  if $::mysql_exists {
    mysql_database { $name:
      ensure  => $ensure,
      require => Service[$mysql::params::myservice]
    }
  } else {
    fail("Mysql binary not found, Fact[::mysql_exists]:${::mysql_exists}")
  }

}
