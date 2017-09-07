# Class to deploy config for uwsgi master process (emperor)
class uwsgi::config (
  Optional[Stdlib::Absolutepath] $configfile,
  Optional[Boolean] $log_rotate,

  # template variables
  Optional[Stdlib::Absolutepath] $logfile,
  Optional[Stdlib::Absolutepath] $app_directory,
  Optional[Stdlib::Absolutepath] $pidfile,
  Optional[Stdlib::Absolutepath] $socket,
  Optional[Boolean] $tyrant,
  Optional[Hash[String[1],Any]] $emperor_options,
){

  # remove config files if package is purged
  $file_ensure = lookup('uwsgi::install::package_ensure') ? {
    'absent' => 'absent',
    'purged' => 'absent',
    default  => 'present'
  }

  file { $configfile:
    ensure  => $file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('uwsgi/uwsgi.ini.erb'),
  }

  if $log_rotate and $file_ensure == 'present' {
    $file_logrotate = 'present'
  } else {
    $file_logrotate = 'absent'
  }

  file { '/etc/logrotate.d/uwsgi':
    ensure  => $file_logrotate,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('uwsgi/uwsgi_logrotate.erb'),
  }
}
