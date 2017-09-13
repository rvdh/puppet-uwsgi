puppet-uwsgi
============

A puppet module for installing and managing uWSGI (in emperor mode)

[![Build Status](https://travis-ci.org/poikilotherm/puppet-uwsgi-wip.svg?branch=refactor_puppet5)](https://travis-ci.org/poikilotherm/puppet-uwsgi-wip)

**WARNING**: version 2.0 and newer of this module _requires_ Puppet 4.7 and newer.
See version 1.3.2 for compatibility with Puppet 3.

## Description

This module installs and configures [uWSGI](http://uwsgi-docs.readthedocs.org)
in [Emperor mode](http://uwsgi-docs.readthedocs.org/en/latest/Emperor.html).

It can also create and manage uWSGI applications that run under the emperor,
which are best defined in Hiera.

Just about every option is configurable, so it should work on most distributions
by putting together a Hiera file.

## Usage

There are two options to get uWSGI going on your machine: either `include uwsgi`
and provide vassal configurations via `uwsgi::app` from Hiera or create
resources via the defined type `uwsgi::app` by yourself (will `include uwsgi`
for you).

If you are using this module on RedHat like distributions, be aware the the uWSGI
or Python pip package is not contained in standard repos. By default, this module
will `include ::epel` from `stahnma/epel` for management (see parameters below).
Remember to include this in your `Puppetfile` if necessary!

### Option 1: `include uwsgi`

1. Add `include uwsgi` to your role or profile class.
2. Add configuration to Hiera (minimal example given):

```yaml
---
uwsgi::app:
  example:
    uid: example
    gid: example
```

Configure multiple applications (merged with [`'deep'` strategy](https://docs.puppet.com/puppet/latest/hiera_merging.html#deep)):

```yaml
# common.yaml
---
uwsgi::app:
  django_1:
    ensure: 'present'
    uid: 'django'
    gid: 'django'
    application_options:
      chdir: '/path/to/project'
      module: 'mysite.wsgi:application'
      socket: '/tmp/uwsgi_django.sock'


# role_app_server.yaml
---
uwsgi::app:
  django_2:
    ensure: 'present'
    uid: 'django'
    gid: 'django'
    application_options:
      chdir: '/path/to/project2'
      module: 'mysite.wsgi:application'
      socket: '/tmp/uwsgi_django2.sock'
```

### Option 2: create `uwsgi::app` resources

1. Add configuration to Hiera (minimal example given):
```yaml
---
apps:
  example:
    uid: example
    gid: example
```
2. Create resources (minimal example):
```puppet
$apps = lookup('apps')
each($app) |$name, $options| {
  uwsgi::app { $name:
    * => $options,
  }
}
```

## Limitations

1. Users for your vassals are NOT managed by this module.
2. This module uses unit testing and acceptance testing for the supported
   operating system versions. Try your luck on other platforms...
3. This module does not support Puppet 3 or Puppet < 4.7 and heavily relies on
   Hiera 5 data-in-modules. Please upgrade.

## Defined Types

### uwsgi::app

Responsible for creating uWSGI applications (vassals) that run under the uWSGI emperor.

#### Parameters

* `uid`
   The user to run the application as. Required.
   May be the user name or the id.

* `gid`
   The group to run the application as. Required.
   May be the group name or the id.

* `ensure`
   Ensure the config file exists.
   Default: `'present'`

* `template`
   The template used to construct the config file.
   Default: `'uwsgi/uwsgi_app.ini.erb'`

* `application_options`
   Hash of extra options to set in the application config file.
   Default: `{}`
   Example: `{ 'socket' => '/tmp/app.socket' }`

* `environment_variables`
   Hash of extra environment variabls to set in the application config file.
   Default: `{}`
   Example: `{ 'DJANGO_ENV_VAR' => 'example' }`

#### Using Hiera

Configure a Django application:

```yaml
---
uwsgi::app:
  django:
    ensure: 'present'
    uid: 'django'
    gid: 'django'
    application_options:
      chdir: '/path/to/project'
      module: 'mysite.wsgi:application'
      socket: '/tmp/uwsgi_django.sock'
      master: 'True'
      vaccum: 'True'
      max-requests: '5000'
      buffer-size: '32768'
      processes: 4
      threads: 8
```

## Classes

### uwsgi

The main entry point. Simply ``include uwsgi`` to accept all the default
parameters. The service file template will, by default, auto-configure itself
depending on the service provider (RedHat init.d / UpStart / SystemD).

#### Parameters

* `app`
   A hash of `uwsgi::app` resources to create for you. See above.
   Default: `{}`

### Private subclasses

Any subclasses of `::uwsgi` are private and normally you should not need to
fiddle around with them. Instead, use parameters configurable via Hiera (see
next section).

## Parameters (via Hiera)

None of the following parameters are required. Depending on your distribution
and version, this provides sane defaults.

If you want to add a new distribution or version, have a look at the `data`
directory of this module.

Most certainly you want to configure some emperor options. Example:
```yaml
---
uwsgi::emperor_options:
  vacuum: 'True'
  reload-mercy: 8
```

### Installation

* `uwsgi::install::package_name` The package name to install.
* `uwsgi::install::package_ensure` Package state. Cascades to config files.
* `uwsgi::install::package_provider` The provider to use to install the package.

#### Build and Runtime dependencies

* `uwsgi::packages::manage_epel` Choose to depend on epel module. Default on RedHat.
* `uwsgi::packages::install_pip` Install pip if it's not already installed? Don't by default.
* `uwsgi::packages::install_python_dev` Install python header files and other build time dependencies if not already installed? Don't by default. Merge strategy "unique".
* `uwsgi::packages::python_dev` String or Array of build time dependency package names.
* `uwsgi::packages::python_pip` String of pip package name.

### Emperor Configuration

* `uwsgi::config::configfile` Absolute path to config file.
* `uwsgi::config::log_rotate` Install logrotate rule? Don't by default.
* `uwsgi::config::app_directory` Absolute path to store vassal configurations.
* `uwsgi::config::pidfile` Absolute path to pid file.
* `uwsgi::config::socket` Absolute path to socket file.
* `uwsgi::config::emperor_options` Hash of extra options for emperor ini file.
* `uwsgi::config::tyrant` Start emperor in "tryant" mode?
* `uwsgi::config::logfile` Absolute path to log file.

### Service

* `uwsgi::service::manage_file` Provide a init system dependent start script/file? (or use package provided)
* `uwsgi::service::provider` Service provider of this system. Depends on your distribution.
* `uwsgi::service::file` Absolute path to script file.
* `uwsgi::service::file_mode` Mode of script file.
* `uwsgi::service::template` Template to use (auto depends on service provider).
* `uwsgi::service::ensure` Service status to ensure. Defaults to `running`.
* `uwsgi::service::enable` Start service at boot? Default to true.
* `uwsgi::service::binary_directory` Aboslute path to uwsgi binary.
* `uwsgi::service::kill_signal` Systemd specific: signal to use for termination of uWSGI.

## Contributers

Contributions will be gratefully accepted.  Please go to the project page,
fork the project, make your changes locally and then raise a pull request.
Details on how to do this are available at
https://guides.github.com/activities/contributing-to-open-source.

### Additional Contributers

**Release**  | **PR/Issue/commit**                                                                                               | **Contributer**
-------------|-------------------------------------------------------------------------------------------------------------------|----------------------------------------
2.0.0        | Refactor for Puppet 5, add RSpec and Beaker tests                                                                 | [@poikilotherm](https://github.com/poikilotherm)
1.3.1        | [Add systemd support for Debian 8](https://github.com/rvdh/puppet-uwsgi/pull/16)                                  | [@rvdh](https://github.com/rvdh)
1.3.0        | [Add systemd support](https://github.com/rvdh/puppet-uwsgi/pull/14)                                               | [@andy-s-clark](https://github.com/andy-s-clark)
1.3.0        | [Make tyrant mode configurable](https://github.com/rvdh/puppet-uwsgi/pull/12)                                     | [@TravellingGuy](https://github.com/TravellingGuy)
1.3.0        | [Additional Options](https://github.com/rvdh/puppet-uwsgi/pull/11)                                                | [@elmerfud](https://github.com/elmerfud)
1.2.0        | [Support repeated application options by passing an array of values](https://github.com/rvdh/puppet-uwsgi/pull/6) | [@rayl](https://github.com/rayl)
1.1.0        | [Fix typo in Upstart script](https://github.com/rvdh/puppet-uwsgi/pull/5)                                         | [@Kodapa](https://github.com/Kodapa)
1.1.0        | [Support multiple env options](https://github.com/rvdh/puppet-uwsgi/pull/4)                                       | [@kimor79](https://github.com/kimor79)
1.0.1        | [Fix logging when using init.d](https://github.com/rvdh/puppet-uwsgi/pull/3)                                      | [@kimor79](https://github.com/kimor79)
1.0.0        | [init.d support](https://github.com/rvdh/puppet-uwsgi/pull/2)                                                     | [@kimor79](https://github.com/kimor79)
0.9.0        |                                                                                                                   | [@jarshwah](https://github.com/jarshwah)
