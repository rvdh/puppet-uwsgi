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
    $service_file        = '/etc/init/uwsgi.conf'
    $service_file_mode   = '0644'
    $service_template    = 'uwsgi/uwsgi_upstart.conf.erb'
    $service_ensure      = true
    $service_enable      = true
    $service_provider    = 'upstart'
    $manage_service_file = true
    $config_file         = '/etc/uwsgi.ini'
    $install_pip         = true
    $install_python_dev  = true
    $python_pip          = 'python-pip'

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
