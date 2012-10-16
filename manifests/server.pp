class mysql::server ($data_dir=undef, $default_storage_engine='InnoDB', $instance_type=undef) {
  case $::operatingsystem {
      redhat, centos: { include mysql::server::redhat }
      default: { fail("${::operatingsystem} is not yet supported") }
  }
}
