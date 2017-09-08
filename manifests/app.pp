# == Define: uwsgi::app
#
# Responsible for creating uwsgi applications. You shouldn't need to use this
# type directly, as the main `uwsgi` class uses this type internally.
#
# === Parameters
#
# [*ensure*]
#    Ensure the config file exists. Default: 'present'
#
# [*template*]
#    The template used to construct the config file.
#    Default: 'uwsgi/uwsgi_app.ini.erb'
#
# [*uid*]
#    The user to run the application as. Required.
#    May be the user name, not just the id.
#
# [*gid*]
#    The group to run the application as. Required.
#    May be the group name, not just the id.
#
# [*application_options*]
#    Extra options to set in the application config file
#
# [*environment_variables*]
#    Extra environment variables to set in the application config file
#
# === Authors
# - Josh Smeaton <josh.smeaton@gmail.com>
#
define uwsgi::app (
  Variant[Integer[0],String[1]] $uid,
  Variant[Integer[0],String[1]] $gid,
  Optional[Enum['present','absent']] $ensure = 'present',
  Optional[String[1]] $template = 'uwsgi/uwsgi_app.ini.erb',
  Optional[Hash[String[1],Scalar]] $application_options = {},
  Optional[Hash[String[1],Scalar]] $environment_variables = {},
  Optional[Stdlib::Absolutepath] $app_dir = lookup('uwsgi::config::app_directory')
) {
  include uwsgi
  file { "${app_dir}/${title}.ini":
    ensure  => $ensure,
    owner   => $uid,
    group   => $gid,
    mode    => '0644',
    content => template($template),
    notify  => Service['uwsgi'],
  }
}
