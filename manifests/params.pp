# == Class: uwsgi::params
# Default parameters for configuring and installing
# uwsgi
#
# === Authors:
# - Josh Smeaton <josh.smeaton@gmail.com>
#
class uwsgi::params {
    $package_name        = 'uwsgi'
    $package_ensure      = 'installed'
    $package_provider    = 'pip'
    $service_name        = 'uwsgi'
    $service_ensure      = true
    $service_enable      = true
    $manage_service_file = true
    $service_provider    = 'upstart'
    $config_file         = '/etc/uwsgi.ini'
    $install_pip         = true
    $install_python_dev  = true
    $log_file            = '/var/log/uwsgi/uwsgi-emperor.log'
    $python_pip          = 'python-pip'
    $pidfile             = '/var/run/uwsgi/uwsgi.pid'
    $socket              = '/var/run/uwsgi/uwsgi.socket'

    case $::osfamily {
        redhat: {
            $app_directory = '/etc/uwsgi.d'
            $python_dev    = 'python-devel'
        }
        default: {
            $app_directory = '/etc/uwsgi/apps-enabled'
            $python_dev    = 'python-dev'
        }
    }
}
