class mysql::server ($data_dir=undef, $default_storage_engine='InnoDB', $innodb_buffer_pool_size=undef, $instance_type=undef) {
  case $::operatingsystem {
      redhat, centos: { include mysql::server::redhat }
      default: { fail("${::operatingsystem} is not yet supported") }
  }
}
