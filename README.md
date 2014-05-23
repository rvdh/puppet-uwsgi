puppet-uwsgi
============

A puppet module for installing and managing uwsgi

## Description

This module installs and configures [uWSGI](http://uwsgi-docs.readthedocs.org)
in [Emperor mode](http://uwsgi-docs.readthedocs.org/en/latest/Emperor.html).

It does not, currently, manage uwsgi applications (PRs welcome).

Just about every option is configurable, so it should work on most distributions
by putting together a hiera file.

## Classes

### uwsgi

The main entry point. Simply ``include uwsgi`` to accept all the default
parameters.

#### Parameters

* `package_name`
   The package name to install.
   Default: 'uwsgi'

* `package_ensure`
   Package state.
   Default: 'installed'

* `package_provider`
   The provider to use to install the package.
   Default: 'pip'

* `service_name`
   The name of the service to run uwsgi.
   Default: 'uwsgi'

* `service_file`
   The location of the service file.
   Default: '/etc/init/uwsgi.conf'

* `service_ensure`
   The service state.
   Default: true

* `service_enable`
   The service onboot state.
   Default: true

* `service_provider`
   The service provider.
   Default: 'upstart'

   `upstart` is required for the default `service_file`, and
   works on RedHat >= 6

* `manage_service_file`
   Whether to override the system service file if it exists.
   Default: true

* `config_file`
   The location of the uwsgi config file.
   Default: '/etc/uwsgi.ini'

* `app_directory`
   Vassal directory for application config files.

   RedHat default: '/etc/uwsgi.d'
   Other default: '/etc/uwsgi/apps-enabled'

* `install_pip`
   Install pip if it's not already installed?
   Default: true

* `install_python_dev`
   Install python header files if not already installed?
   Default: true

* `python_pip`
   Package to be installed for pip
   Default: 'python-pip'

* `python_dev`
   Package to be installed for python headers
   Default RedHat: 'python-devel'
   Default Other: 'python-dev'

* `emperor_options`
   Extra options to set in the emperor config file. Default: undef

#### Using Hiera

Hiera can be (should be!) used to change any of the default uwsgi parameters.

Sets up some custom options within the emperor config file:

```yaml
---
uwsgi::emperor_options:
  vacuum: 'True'
  reload-mercy: 8
```

Don't manage python or pip, and use apt-get to install uwsgi. Don't manage
the service file, as it will be provided by the package itself:

```yaml
---
uwsgi::install_pip: false
uwsgi::install_python_dev: false
uwsgi::package_provider: 'apt'
uwsgi::manage_service_file: false
```

Remove uwsgi:

```yaml
---
uwsgi::package_ensure: 'absent'
uwsgi::service_ensure: false
uwsgi::service_enable: false
uwsgi::install_pip: false
uwsgi::install_python_dev: false
```
