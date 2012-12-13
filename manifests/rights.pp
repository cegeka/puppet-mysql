# == Definition: mysql::rights
#
# A basic helper used to create a user and grant him some privileges on a database.
#
# Example usage:
#  mysql::rights { "example case":
#    user     => "foo",
#    password => "bar",
#    database => "mydata",
#    priv    => ["select_priv", "update_priv"]
#  }
#
#Available parameters:
#- *$ensure": defaults to present
#- *$database*: the target database
#- *$user*: the target user
#- *$password*: user's password
#- *$host*: target host, default to "localhost"
#- *$priv*: target privileges, defaults to "all" (values are the fieldnames from mysql.db table).

define mysql::rights($database, $user, $password, $host='localhost', $ensure='present', $priv='all') {

  if $::mysql_exists {
    if $ensure == 'present' {
      if ! defined(Mysql_user ["${user}@${host}"]) {
        mysql_user { "${user}@${host}":
          password_hash => mysql_password($password),
          require       => File[$mysql::params::mylocalcnf],
        }
      }

      mysql_grant { "${user}@${host}/${database}":
        privileges  => $priv,
        require     => File[$mysql::params::mylocalcnf],
      }
    }
    if $ensure == 'absent' {
      if defined(Mysql_user ["${user}@${host}"]) {
        mysql_user { "${user}@${host}":
          ensure => absent
        }
      }
    }
  } else {
    fail("Mysql binary not found, Fact[::mysql_exists]:${::mysql_exists}")
  }


}
