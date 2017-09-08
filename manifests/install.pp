# Class to install uWSGI
class uwsgi::install (
  Optional[String[1]] $package_name,
  Optional[String[1]] $package_ensure,
  Optional[String[1]] $package_provider,
){

  # dependencies
  include uwsgi::packages
  # install via provider
  package { $package_name:
    ensure   => $package_ensure,
    provider => $package_provider,
    require  => Class['uwsgi::packages'],
  }

  File {
    ensure  => 'directory',
    require => Package[$package_name],
  }

  $log_directory = dirname(lookup('uwsgi::config::logfile'))
  $pid_directory = dirname(lookup('uwsgi::config::pidfile'))
  $socket_directory = dirname(lookup('uwsgi::config::socket'))
  $app_directory = lookup('uwsgi::config::app_directory')

  file { $log_directory: }
  file { $pid_directory: }
  if $socket_directory != $pid_directory {
    file { $socket_directory: }
  }
  file { $app_directory: }
}
