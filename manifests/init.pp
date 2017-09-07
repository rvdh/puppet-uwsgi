# == Class: uwsgi
#
# This class installs and configures uWSGI Emperor service. By default,
# it will use pip to install uwsgi, so you need to make sure that pip
# is available on the system. You will also need to ensure that
# the python development headers are installed so that uwsgi can build.
#
# === Parameters
#
# [*app*]
#    Hash of uwsgi::app resources to create.
#    Default: {}
#
# === Authors
# - Josh Smeaton <josh.smeaton@gmail.com>
# - Oliver Bertuch <oliver@bertuch.eu>
#
class uwsgi (
  Optional[Hash[String[1],Any]] $app = {},
) {
  include uwsgi::install
  include uwsgi::config
  include uwsgi::service

  # finally, configure any applications necessary
  if $app {
    each($app) |$name, $options| {
      uwsgi::app { $name:
        * => $options,
      }
    }
  }
}
