class mysql::params {

  $mycnf = $::operatingsystem ? {
    /RedHat|Fedora|CentOS/  => '/etc/my.cnf',
    default                 => '/etc/mysql/my.cnf',
  }

  $myservice = $::operatingsystem ? {
    /RedHat|Fedora|CentOS/  => 'mysqld',
    default                 => 'mysql',
  }

  $mycnfctx = "/files${mycnf}"
  $mylocalcnf = '/root/.my.cnf'

  if ! $mysql::server::data_dir {
    $real_data_dir = '/var/lib/mysql'
  } else {
    $real_data_dir = $mysql::server::data_dir
  }

  if ! $mysql::server::instance_type {
    $real_instance_type = 'medium'
  } else {
    $real_instance_type = $mysql::server::instance_type
  }

  #$replication_binlog_format = $replication_binlog_format ? {
  #  ''      => 'STATEMENT',
  #  default => $replication_binlog_format,
  #}

}
