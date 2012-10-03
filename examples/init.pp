class { 'mysql::server':
  data_dir => '/data/mysql',
}

mysql::database { 'testdb':
  ensure => present
}

mysql::rights { 'testdb':
  ensure   => present,
  database => 'testdb',
  user     => 'testuser',
  password => 'testpwd',
}
