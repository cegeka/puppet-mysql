class mysql::server::redhat {
  include mysql::params

  case $mysql::params::real_instance_type {
    small: { include mysql::config::performance::small }
    medium: { include mysql::config::performance::medium }
    large: { include mysql::config::performance::large }
    default: { fail('Unknown instance type') }
  }

  package { 'mysql-server':
    ensure => installed,
  }

  service { $mysql::params::myservice:
    ensure      => running,
    enable      => true,
    hasrestart  => true,
    hasstatus   => true,
    require     => Package['mysql-server'],
  }

  file { $mysql::params::real_data_dir :
    ensure  => directory,
    owner   => 'mysql',
    group   => 'mysql',
    require => Package['mysql-server'],
  }

  file { '/etc/my.cnf':
    ensure  => present,
    path    => $mysql::params::mycnf,
    owner   => root,
    group   => root,
    mode    => '0644',
    require => Package['mysql-server'],
  }

  file { '/etc/logrotate.d/mysql-server':
    ensure  => present,
    content => template('mysql/logrotate.redhat.erb'),
  }

  if $mysql::params::mysql_user { $real_mysql_user = $mysql::params::mysql_user } else { $real_mysql_user = 'root' }

  if $mysql::params::mysql_password {

    $real_mysql_user = $mysql::params::mysql_user

    if $mysql::mysql_exists == true {
      mysql_user { "${real_mysql_user}@localhost":
        ensure        => present,
        password_hash => mysql_password($real_mysql_password),
        require       => Exec['gen-my.cnf'],
      }
    }

    file { $mysql::params::mylocalcnf:
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => '0600',
      content => template('mysql/my.cnf.erb'),
      require => Exec['init-rootpwd'],
    }

  } else {

    #$real_mysql_password = generate("/usr/bin/pwgen", 20, 1)
    $real_mysql_password = ''

    file { $mysql::params::mylocalcnf:
      owner   => root,
      group   => root,
      mode    => '0600',
      require => Exec['init-rootpwd'],
    }

  }

  exec { 'init-rootpwd':
    unless  => "/usr/bin/test -f ${mysql::params::mylocalcnf}",
    command => "/usr/bin/mysqladmin -u${real_mysql_user} password \"${real_mysql_password}\"",
    notify  => Exec['gen-my.cnf'],
    require => [Package['mysql-server'], Service[$mysql::params::myservice]]
  }

  exec { 'gen-my.cnf':
    command     => "/bin/echo -e \"[mysql]\nuser=${real_mysql_user}\npassword=${real_mysql_password}\nsocket=${$mysql::params::real_data_dir}/mysql.sock\n[mysqladmin]\nuser=${real_mysql_user}\npassword=${real_mysql_password}\nsocket=${$mysql::params::real_data_dir}/mysql.sock\n[mysqldump]\nuser=${real_mysql_user}\npassword=${real_mysql_password}\nsocket=${$mysql::params::real_data_dir}\n[mysqlshow]\nuser=${real_mysql_user}\npassword=${real_mysql_password}\nsocket=${$mysql::params::real_data_dir}/mysql.sock\n\" > /root/.my.cnf",
    refreshonly => true,
    creates     => '/root/.my.cnf'
  }

}
