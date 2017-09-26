# Class to install uWSGI
class uwsgi::install (
  Optional[String[1]] $package_name,
  Optional[Enum['present','purged','absent']] $package_ensure,
  Optional[Enum['pip','apt','yum']] $package_provider,
  Optional[Array[String[1]]] $plugins = lookup('uwsgi::plugins'),
){

  # dependencies
  include ::uwsgi::packages
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

  # if installation is via pip, ensure the directory tree is present
  # (needed on Debian systems)
  if $package_provider == 'pip' {
    exec { 'uwsgi-mkdir-app-dir':
      creates => $app_directory,
      command => "mkdir -p ${app_directory}",
      path    => $::path,
    }
  }
  file { $app_directory: }

  # if we don't install via pip, install plugins
  if $package_provider != 'pip' {
    ensure_packages($plugins, {'ensure' => $package_ensure, 'provider' => $package_provider})
  }
}
