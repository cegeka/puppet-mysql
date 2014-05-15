class mysql::config::performance::large {
  mysql::config {
    'datadir': value                        => $mysql::params::real_data_dir;
    'socket': value                         => "${mysql::params::real_data_dir}/mysql.sock";
    'default-storage-engine': value         => $mysql::params::real_default_storage_engine;
    'key_buffer': value                     => '256M';
    'max_allowed_packet': value             => '25M';
    'sort_buffer_size': value               => '1M';
    'read_buffer_size': value               => '1M';
    'read_rnd_buffer_size': value           => '4M';
    'net_buffer_length': value              => '8K';
    'myisam_sort_buffer_size': value        => '8M';
    'thread_cache_size': value              => '8';
    'query_cache_size': value               => '16M';
    'thread_concurrency': value             => '8';
    'thread_stack': ensure                  => absent;
    'log_bin': value                        => $::fqdn;
    'mysqld_dump/max_allowed_packet': value => '16M';
    'isamchk/key_buffer': value             => '128M';
    'isamchk/sort_buffer_size': value       => '128M';
    'isamchk/read_buffer': value            => '2M';
    'isamchk/write_buffer': value           => '2M';
    'myisamchk/key_buffer': value           => '128M';
    'myisamchk/sort_buffer_size': value     => '128M';
    'myisamchk/read_buffer': value          => '2M';
    'myisamchk/write_buffer': value         => '2M';
    'client/socket': value                  => "${mysql::params::real_data_dir}/mysql.sock";
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
      value => '256'
    }
  }
  else {
    mysql::config { 'table_open_cache' :
      value => '256'
    }
  }
}
