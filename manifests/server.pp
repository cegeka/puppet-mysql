class mysql::server (
  $data_dir=undef,
  $default_storage_engine='InnoDB',
  $innodb_buffer_pool_size=undef,
  $instance_type=undef,
  $mysql_libs_obsolete=false,
  $mysql_service_name_override=undef,
  $log_bin=$::fqdn,
  $expire_logs_days='3',
  $implementation=undef
) {

  case $::operatingsystem {
      redhat, centos: { include mysql::server::redhat }
      default: { fail("${::operatingsystem} is not yet supported") }
  }

}
