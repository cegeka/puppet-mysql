# == Definition: mysql::rights
#
# A basic helper used to create a user and grant him some privileges on a database.
#
# Example usage:
#  mysql::rights { "example case":
#    user       => "foo",
#    password   => "bar",
#    database   => "mydata",
#    priv       => ["select_priv", "update_priv"],
#    sectret_id => 123456
#  }
#
#Available parameters:
#- *$ensure": defaults to present
#- *$database*: the target database
#- *$user*: the target user
#- *$password*: user's password
#- *$secretid*: the ID for PIM
#- *$host*: target host, default to "localhost"
#- *$priv*: target privileges, defaults to "all" (values are the fieldnames from mysql.db table).

define mysql::rights(
  $database,
  $user,
  $password=undef,
  $secretid=undef,
  $host='localhost',
  $ensure='present',
  $priv='all'
) {

  if $::mysql_exists {
    if $secretid == undef and $password == undef {
      fail("You must privide a password or a secretid to ::mysql::rights")
    }

    if $secretid != undef {
      $mysql_password = getsecret($secretid, 'Password')
    } else {
      $mysql_password = $password
    }

    ensure_resource('mysql_user', "${user}@${host}", {
      ensure        => $ensure,
      password_hash => mysql_password($mysql_password),
      provider      => 'mysql',
      require       => File[$mysql::params::mylocalcnf],
    })

    if $ensure == 'present' {
      mysql_grant { "${user}@${host}/${database}":
        privileges => $priv,
        provider   => 'mysql',
        require    => Mysql_user["${user}@${host}"],
      }
    }

  } else {
    fail("Mysql binary not found, Fact[::mysql_exists]:${::mysql_exists}")
  }
}
