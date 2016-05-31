class mysql::params {

  $mycnf = $::operatingsystem ? {
    /RedHat|Fedora|CentOS/  => '/etc/my.cnf',
    default                 => '/etc/mysql/my.cnf',
  }

  if $mysql::server::mysql_service_name_override {
    $myservice = $mysql::server::mysql_service_name_override
  } else {
    if ($mysql::server::implementation == 'mariadb') {
      $myservice = 'mariadb';
    } else {
      $myservice = $::operatingsystem ? {
        /RedHat|Fedora|CentOS/  => 'mysqld',
        default                 => 'mysql',
      }
    }
  }

  $mycnfctx = "/files${mycnf}"
  $mylocalcnf = '/root/.my.cnf'

  if ! $mysql::server::data_dir {
    $real_data_dir = '/var/lib/mysql'
  } else {
    $real_data_dir = $mysql::server::data_dir
  }

  if $mysql::server::default_storage_engine in ['MyISAM', 'InnoDB', 'IBMDB2I', 'MERGE', 'MEMORY', 'EXAMPLE', 'FEDERATED', 'ARCHIVE', 'CSV', 'BLACKHOLE'] {
    $real_default_storage_engine = $mysql::server::default_storage_engine
  } else {
    fail('Mysql::Params: parameter default_storage_engine must be one of the following: "MyISAM", "InnoDB", "IBMDB2I", "MERGE", "MEMORY", "EXAMPLE", "FEDERATED", "ARCHIVE", "CSV", "BLACKHOLE"')
  }

  $real_innodb_buffer_pool_size = $mysql::server::innodb_buffer_pool_size

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
