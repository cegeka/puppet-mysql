define mysql::database($ensure) {
    if $::mysql_exists {
    mysql_database { $name:
      ensure => $ensure,
    }
    } else {
      fail("Mysql binary not found, Fact[::mysql_exists]:${::mysql_exists}")
    }
}
