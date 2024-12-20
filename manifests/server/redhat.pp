# Class: mysql::server::redhat
#
# Usage: this class should not be called directly
#
class mysql::server::redhat {

  include mysql::params

  case $mysql::params::real_instance_type {
    'small': { include mysql::config::performance::small }
    'medium': { include mysql::config::performance::medium }
    'large': { include mysql::config::performance::large }
    default: { fail('Unknown instance type') }
  }

  if ($mysql::server::implementation == 'mariadb') {
    $mysql_server_dependencies = ['mariadb-server']
  } elsif ($mysql::server::implementation == 'mysql-community') {
    $mysql_server_dependencies = ['mysql-community-server']
  } else {
    if $mysql::server::mysql_libs_obsolete {
      case $facts['os']['release']['major'] {
        '6': { $mysql_server_dependencies = ['mysql-server'] }
        '7': { $mysql_server_dependencies = ['mariadb-server'] }
        default: { fail('Unsupported OS major release') }
      }
    } else {
      case $facts['os']['release']['major'] {
        '6': { $mysql_server_dependencies = ['mysql-server','mysql-libs'] }
        '7': { $mysql_server_dependencies = ['mariadb-server','mariadb-libs'] }
        default: { fail('Unsupported OS major release') }
      }
    }
  }

  package { $mysql_server_dependencies:
    ensure  => installed,
    require => File['/etc/my.cnf']
  }

  if $facts['os']['selinux']['enabled'] == true {
    service { $mysql::params::myservice:
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
      require    => [ Package[$mysql_server_dependencies],
                      File["/etc/init.d/${mysql::params::myservice}"],
                      File[$mysql::params::real_data_dir],
                      File_line['selinux_context_mysql_datadir'] ],
    }

    file_line { 'selinux_context_mysql_datadir':
      path => '/etc/selinux/targeted/contexts/files/file_contexts',
      line => "${mysql::params::real_data_dir}(/.*)? system_u:object_r:mysqld_db_t:s0"
    }

    file { $mysql::params::real_data_dir :
      ensure  => directory,
      owner   => 'mysql',
      group   => 'mysql',
      seltype => 'mysqld_db_t',
      require => [ Package[$mysql_server_dependencies], File_line['selinux_context_mysql_datadir'] ],
    }
  } else {
    service { $mysql::params::myservice:
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
      require    => [ Package[$mysql_server_dependencies],
                      File["/etc/init.d/${mysql::params::myservice}"],
                      File[$mysql::params::real_data_dir] ]
    }

    file { $mysql::params::real_data_dir :
      ensure => directory,
      owner  => 'mysql',
      group  => 'mysql',
      require => Package[$mysql_server_dependencies],
    }

  }

  file { '/etc/my.cnf':
    ensure => present,
    path   => $mysql::params::mycnf,
    owner  => root,
    group  => root,
    mode   => '0644',
  }

  file { "/etc/init.d/${mysql::params::myservice}":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0755',
    content => template("${module_name}/mysqld.erb"),
    require => Package[$mysql_server_dependencies],
  }

  file { '/etc/sysconfig/mysqld':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template("${module_name}/mysqld.sysconfig.erb"),
    require => Package[$mysql_server_dependencies],
  }

  file { '/var/run/mysqld':
    ensure  => directory,
    owner   => mysql,
    group   => mysql,
    mode    => '0755',
    require => Package[$mysql_server_dependencies],
  }

  file { '/etc/logrotate.d/mysql-server':
    ensure  => present,
    content => template('mysql/logrotate.redhat.erb'),
  }

  $real_mysql_user = 'root'

  #$real_mysql_password = generate("/usr/bin/pwgen", 20, 1)
  $real_mysql_password = ''

  file { $mysql::params::mylocalcnf:
    owner   => root,
    group   => root,
    mode    => '0600',
    require => Exec['init-rootpwd'],
  }

  exec { 'init-rootpwd':
    unless  => "/usr/bin/test -f ${mysql::params::mylocalcnf}",
    command => "/usr/bin/mysqladmin -S ${mysql::params::real_data_dir}/mysql.sock -u${real_mysql_user} password \"${real_mysql_password}\"",
    notify  => Exec['gen-my.cnf'],
    require => [ Package[$mysql_server_dependencies], Service[$mysql::params::myservice] ]
  }

  exec { 'gen-my.cnf':
    command     => "/bin/echo -e \"[mysql]\nuser=${real_mysql_user}\npassword=${real_mysql_password}\n[mysqladmin]\nuser=${real_mysql_user}\npassword=${real_mysql_password}\n[mysqldump]\nuser=${real_mysql_user}\npassword=${real_mysql_password}\n[mysqlshow]\nuser=${real_mysql_user}\npassword=${real_mysql_password}\n[client]\nsocket=${mysql::params::real_data_dir}/mysql.sock\n\" > /root/.my.cnf ; chmod 600 /root/.my.cnf",
    refreshonly => true,
    creates     => '/root/.my.cnf'
  }

}
