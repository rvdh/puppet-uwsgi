# == Class: uwsgi
#
# This class installs and configures uWSGI Emperor service. By default,
# it will use pip to install uwsgi, so you need to make sure that pip
# is available on the system. You will also need to ensure that
# the python development headers are installed so that uwsgi can build.
#
# === Parameters
#
# [*package_name*]
#    The package name to install. Default: 'uwsgi'
#
# [*package_ensure*]
#    Package state. Default: 'installed'
#
#    If 'absent' or 'purged', then remove the `service_file` and `config_file`
#    also
#
# [*package_provider*]
#    The provider to use to install the package. Default: 'pip'
#
# [*service_name*]
#    The name of the service to run uwsgi. Default: 'uwsgi'
#
# [*service_file*]
#    The location of the service file. Default: '/etc/init/uwsgi.conf'
#
# [*service_file_mode*]
#    The mode of the service file. Default: '0644'
#
# [*service_template*]
#    The location of the template to generate the *service_file*.
#    Default: 'uwsgi/uwsgi_upstart.conf.erb'
#
# [*service_ensure*]
#    The service state. Default: true
#
# [*service_enable*]
#    The service onboot state. Default: true
#
# [*service_provider*]
#    The service provider. Default: 'upstart'
#    'upstart' is required for the default service_file, and
#    works on RedHat 6.
#    'systemd' works on RedHat 7 and Debian 8.
#
# [*manage_service_file*]
#    Whether to override the system service file if it exists. Default: true
#
# [*binary_directory*]
#    Directory containing the uwsgi binary. Used by the 'systemd'
#    service_provider, but not 'upstart' or 'redhat'.
#
# [*config_file*]
#    The location of the uwsgi config file. Default: '/etc/uwsgi.ini'
#
# [*log_file*]
#    The location of the uwsgi emperor log.
#    Default: '/var/log/uwsgi/uwsgi-emperor.log'
#
# [*log_rotate]
#    Whether or not to deploy a logrotate script.
#    Accepts: 'yes', 'no', 'purge'
#    Default: 'no'
#
# [*app_directory*]
#    Vassal directory for application config files
#
# [*tyrant*]
#   Whether to run the emperor in tyrant mode
#   Default: true
#
# [*install_pip*]
#    Install pip if it's not already installed?
#    Default: true
#
# [*install_python_dev*]
#    Install python header files if not already installed?
#    Default: true
#
# [*python_pip*]
#    Package to be installed for pip
#    Default: 'python-pip'
#
# [*python_dev*]
#    Package to be installed for python headers
#    Default RedHat: 'python-devel'
#    Default Other: 'python-dev'
#
# [*emperor_options*]
#    Extra options to set in the emperor config file
#
# === Authors
# - Josh Smeaton <josh.smeaton@gmail.com>
#
class uwsgi (
    $package_name        = $uwsgi::params::package_name,
    $package_ensure      = $uwsgi::params::package_ensure,
    $package_provider    = $uwsgi::params::package_provider,
    $service_name        = $uwsgi::params::service_name,
    $service_file        = undef,
    $service_file_mode   = undef,
    $service_template    = undef,
    $service_ensure      = $uwsgi::params::service_ensure,
    $service_enable      = $uwsgi::params::service_enable,
    $service_provider    = $uwsgi::params::service_provider,
    $manage_service_file = $uwsgi::params::manage_service_file,
    $binary_directory    = $uwsgi::params::binary_directory,
    $config_file         = $uwsgi::params::config_file,
    $log_file            = $uwsgi::params::log_file,
    $log_rotate          = $uwsgi::params::log_rotate,
    $app_directory       = $uwsgi::params::app_directory,
    $tyrant              = $uwsgi::params::tyrant,
    $install_pip         = $uwsgi::params::install_pip,
    $install_python_dev  = $uwsgi::params::install_python_dev,
    $python_pip          = $uwsgi::params::python_pip,
    $python_dev          = $uwsgi::params::python_dev,
    $pidfile             = $uwsgi::params::pidfile,
    $socket              = $uwsgi::params::socket,
    $emperor_options     = undef
) inherits uwsgi::params {

    validate_re($log_rotate, '^yes$|^no$|^purge$')

    if ! defined(Package[$python_dev]) and $install_python_dev {
        package { $python_dev:
            ensure => present,
            before => Package[$package_name]
        }
    }

    if ! defined(Package[$python_pip]) and $install_pip {
        package { $python_pip:
            ensure => present,
            before => Package[$package_name]
        }
    }

    package { $package_name:
        ensure   => $package_ensure,
        provider => $package_provider
    }

    # remove config files if package is purged
    $file_ensure = $package_ensure ? {
        'absent' => 'absent',
        'purged' => 'absent',
        default  => 'present'
    }

    file { $config_file:
        ensure  => $file_ensure,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('uwsgi/uwsgi.ini.erb'),
        require => Package[$package_name]
    }

    if $manage_service_file == true {
      if $service_file == undef {
          $service_file_real = $service_provider ? {
              redhat  => '/etc/init.d/uwsgi',
              upstart => '/etc/init/uwsgi.conf',
              systemd => '/etc/systemd/system/uwsgi.service',
              default => '/etc/init/uwsgi.conf',
          }
      } else {
          $service_file_real = $service_file
      }

      if $service_file_mode == undef {
          $service_file_mode_real = $service_provider ? {
              redhat  => '0555',
              upstart => '0644',
              systemd => '0644',
              default => '0644',
          }
      } else {
          $service_file_mode_real = $service_file_mode
      }

      if $service_template == undef {
          $service_template_real = $service_provider ? {
              redhat  => 'uwsgi/uwsgi_service-redhat.erb',
              upstart => 'uwsgi/uwsgi_upstart.conf.erb',
              systemd => 'uwsgi/uwsgi_systemd.service.erb',
              default => 'uwsgi/uwsgi_upstart.conf.erb',
          }
      } else {
          $service_template_real = $service_template
      }

      file { $service_file_real:
          ensure  => $file_ensure,
          owner   => 'root',
          group   => 'root',
          mode    => $service_file_mode_real,
          replace => $manage_service_file,
          content => template($service_template_real),
          require => Package[$package_name]
      }
      $required_files = [ $config_file, $service_file_real ]

      if $service_provider == 'systemd' {
        exec { 'uwsgi-reload-systemd':
          command     => '/bin/systemctl daemon-reload',
          refreshonly => true,
          subscribe   => File[$service_file_real],
          before      => Service[$service_name],
        }
      }
    } else {
      $required_files = $config_file
    }

    $log_directory = dirname($log_file)
    $pid_directory = dirname($pidfile)
    $socket_directory = dirname($socket)

    exec { $log_directory:
        creates => $log_directory,
        command => "/bin/mkdir -p ${log_directory}",
        path    => $::path
    } -> file { $log_directory: }

    exec { $pid_directory:
        creates => $pid_directory,
        command => "/bin/mkdir -p ${pid_directory}",
        path    => $::path
    } -> file { $pid_directory: }

    if $socket_directory != $pid_directory {
      exec { $socket_directory:
          creates => $socket_directory,
          command => "/bin/mkdir -p ${socket_directory}",
          path    => $::path
      } -> file { $socket_directory: }
    }

    file { $app_directory:
        ensure  => 'directory',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package[$package_name]
    }

    service { $service_name:
        ensure     => $service_ensure,
        enable     => $service_enable,
        hasrestart => true,
        hasstatus  => true,
        provider   => $service_provider,
        require    => [
            Package[$package_name],
            File[$required_files],
            File[$log_directory],
            File[$pid_directory],
            File[$socket_directory],
            ],
        subscribe  => File[$required_files]
    }

    case $log_rotate {
        'yes': {
            file { '/etc/logrotate.d/uwsgi':
                ensure  => 'file',
                owner   => 'root',
                group   => 'root',
                mode    => '0644',
                content => template('uwsgi/uwsgi_logrotate.erb'),
            }
        }
        default: {
            file { '/etc/logrotate.d/uwsgi':
                ensure  => 'absent',
            }
        }
    }

    # finally, configure any applications necessary
    $applications = hiera_hash('uwsgi::app', {})
    create_resources('uwsgi::app', $applications)
}
