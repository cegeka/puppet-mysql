class mysql::server (
  $data_dir=undef,
  $default_storage_engine='InnoDB',
  $innodb_buffer_pool_size=undef,
  $innodb_log_file_size=undef,
  $instance_type=undef,
  $mysql_libs_obsolete=false,
  $mysql_service_name_override=undef,
  $log_bin=$facts['networking']['fqdn'],
  $expire_logs_days='3',
  $implementation=undef
) {

  case $facts['os']['name'] {
      'RedHat', 'CentOS': { include mysql::server::redhat }
      default: { fail("${facts['os']['name']} is not yet supported") }
  }

}
