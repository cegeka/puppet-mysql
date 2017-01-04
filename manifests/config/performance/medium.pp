class mysql::config::performance::medium {

  mysql::config {
    'datadir': value                        => $mysql::params::real_data_dir;
    'socket': value                         => "${mysql::params::real_data_dir}/mysql.sock";
    'default-storage-engine': value         => $mysql::params::real_default_storage_engine;
    'key_buffer': value                     => '16M';
    'max_allowed_packet': value             => '1M';
    'sort_buffer_size': value               => '512K';
    'read_buffer_size': value               => '256K';
    'read_rnd_buffer_size': value           => '512K';
    'net_buffer_length': value              => '8K';
    'myisam_sort_buffer_size': value        => '8M';
    'thread_cache_size': ensure             => absent;
    'query_cache_size': ensure              => absent;
    'thread_concurrency': ensure            => absent;
    'thread_stack': ensure                  => absent;
    'log_bin': value                        => $mysql::server::log_bin;
    'expire_logs_days': value               => $mysql::server::expire_logs_days;
    'mysqld_dump/max_allowed_packet': value => '16M';
    'isamchk/key_buffer': value             => '20M';
    'isamchk/sort_buffer_size': value       => '20M';
    'isamchk/read_buffer': value            => '2M';
    'isamchk/write_buffer': value           => '2M';
    'myisamchk/key_buffer': value           => '20M';
    'myisamchk/sort_buffer_size': value     => '20M';
    'myisamchk/read_buffer': value          => '2M';
    'myisamchk/write_buffer': value         => '2M';
  }

  if ($mysql::params::real_default_storage_engine == 'InnoDB') {
    mysql::config { 'innodb_file_per_table' :
      value => '1'
    }

    if ( $mysql::params::real_innodb_buffer_pool_size != undef ) {
      mysql::config { 'innodb_buffer_pool_size' :
        value => $mysql::params::real_innodb_buffer_pool_size
      }
    }
  }

  if ( $::osfamily == 'RedHat' and $::operatingsystemrelease =~ /^5\./ ) {
    mysql::config { 'table_cache' :
      value => '64'
    }
  }
  else {
    mysql::config { 'table_open_cache' :
      value => '64'
    }
  }

}
