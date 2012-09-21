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

  #$data_dir = $mysql_data_dir ? {
  #  ""       => "/var/lib/mysql",
  #  default  => $mysql_data_dir,
  #}

  #$backup_dir = $mysql_backupdir ? {
  #  ''      => '/var/backups/mysql',
  #  default => $mysql_backupdir,
  #}

  #$replication_binlog_format = $replication_binlog_format ? {
  #  ''      => 'STATEMENT',
  #  default => $replication_binlog_format,
  #}

  #$logfile_group = $mysql_logfile_group ? {
  #  ''       => $::operatingsystem ? {
  #      'RedHat'  => 'mysql',
  #      'Debian'  => 'adm',
  #      default   => 'adm',
  #    },
  #  default  => $mysql_logfile_group,
  #}

}
