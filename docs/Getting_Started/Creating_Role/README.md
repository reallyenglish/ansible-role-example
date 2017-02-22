Table of Contents
=================

  * [Table of Contents](#table-of-contents)
  * [Creating a role](#creating-a-role)
    * [Creating a role with qansible init](#creating-a-role-with-qansible-init)
  * [Static testing with qansible qa](#static-testing-with-qansible-qa)
  * [Rules](#rules)
    * [Make it dumb](#make-it-dumb)
    * [Use validate where possible](#use-validate-where-possible)
    * [Support multiple platforms](#support-multiple-platforms)
  * [Directory hier](#directory-hier)
    * [defaults](#defaults)
    * [extra_modules](#extra_modules)
    * [filter_plugins](#filter_plugins)
    * [Gemfile and Gemfile.lock](#gemfile-and-gemfilelock)
    * [handlers/main.yml](#handlersmainyml)
    * [Jenkinsfile](#jenkinsfile)
    * [LICENSE](#license)
    * [meta/main.yml](#metamainyml)
    * [Rakefile](#rakefile)
    * [README.md](#readmemd)
    * [tasks](#tasks)
    * [tasks/main.yml](#tasksmainyml)
    * [tasks/install-{{ ansible_os_family }}.yml](#tasksinstall--ansible_os_family-yml)
    * [tasks/configure-{{ ansible_os_family }}.yml](#tasksconfigure--ansible_os_family-yml)
    * [templates](#templates)
    * [tests](#tests)
    * [tests/serverspec](#testsserverspec)
    * [tests/serverspec/default.yml](#testsserverspecdefaultyml)
    * [tests/serverspec/default_spec.rb](#testsserverspecdefault_specrb)
    * [tests/serverspec/spec_helper.rb](#testsserverspecspec_helperrb)
    * [vars/{{ ansible_os_family }}.yml](#vars-ansible_os_family-yml)
    * [Next step](#next-step)

# Creating a role

When creating a role, use
[qansible](https://github.com/trombik/qansible) It creates all directories and
files.

## Creating a role with `qansible init`

Download and install [`qansible`](https://github.com/trombik/qansible).

```
> qansible init ansible-role-foo
```

Run:

```sh
> cd ansible-role-foo
> bundle install
```

# Static testing with `qansible qa`

```sh
> qansible qa
```

It performs static analysis on files and directory. All critical errors must be
fixed. Some warnings may be ignored but should be fixed as well.

You should run `qansible qa` before you push the repository because old roles
may not be up-to-date with the latest best practice. The default `.travis.yml`
created by `qansible` performs `qansible qa`. When `qansible qa` succeeds in
your local environment, but not in Travis CI, `qansible qa` might be old.
Update `qansible qa` and try again.

See the usage by:

```sh
qansible qa --help
```

# Rules

## Make it dumb

Many `ansible` roles publicly published often has magical variables that do
_everything for you_, such as `foo_enable_failover` which computes various
values, creates templates with all the necessary configurations for a service
to failover and executes several other tasks. This almost always leads to a
_black box_ role. Black box role is a role that is easy to use (all you need is
pushing a single button) but hard to understand and debug when something goes
wrong.

Instead, explicitly require the user to configure (almost) everything. A good
role should not require users to understand it but should be easy even when the
user does not know about the role. You should assume that the user knows the
application. Do not make it novice-friendly.

Dumb role make it possible to configure the application in a way beyond the
author's assumption. Intelligent one is easy at first but it becomes hard when
user's requirements are different from the assumption.

## Use `validate` where possible

In `template`, `file`, `copy`, and other tasks that supports validation, use
`validate`. This is not always possible because the validation is performed in
a different context, notably, the file location is not identical. See the
workaround at FIXME if that is the case.

## Support multiple platforms

A role should support at the least:

* the platform you actually use in production
* FreeBSD, Ubuntu, CentOS, and OpenBSD

By supporting other platforms,

* bugs that do not show up in a platform would be found
* the role would be scrutinized 
* you would learn other practices by different vendors

## Fixed package version should be avoided

In some public roles, fixed versions are sometimes used. Some even has a
variable to specify version of a package. However, fixed version should be
avoided because:

* it is inevitable to use the latest packages these days
* if a user needs specific version of a package, the user should maintain and
  host the package
* a role cannot support every version of a package (we will try but only on
  best-effort basis
* roles must be updated whenever upstream updates version or patch level, which
  occur frequently
* in most cases, different version of a package for platform version is
  provided, thus users have to know exact version number for the OS

However, there are cases where you need to install specific version of
packages. The most notable example is Java. Multiple versions of Java SDKs are
officially supported and some Java application require specific version.
Another case is, when upstreams have multiple version of packages in a
packaging system. In the past, most of distributions provided two Apache
packages, 1.x and 2.x. There are a few options for this case.

* Support multiple versions in a single role (`ansible-role-nsd`)
* Provide the default version of the role and let users to choose (`ansible-role-java`)
* Drop support for older version (`ansible-role-jenkins-master`)
* Create different roles for different versions

It depends on various factors to choose an option from the above. The first one
is an ideal for users, but the cost is expensive, or it is possible only when
the differences are small. The second option is reasonable but it has the same
problems as in the first one. The third one looks practical in most cases.
Jenkins 2.x has many incompatibilities and behaves very differently from 1.x,
and there are no reason to use 1.x for new deployment. The forth one should be
chosen when both version are widely used, e.g. apache in the past, and
maintaining 2.x and 1.x was not practical.

# Directory hier

## defaults

The directory of default values.

## extra_modules

Extra ansible modules go here.

## filter_plugins

Jinja2 filter plugins go here.

## Gemfile and Gemfile.lock

Required gems are installed by `bundler`.

## handlers/main.yml

All the handlers that are called by ansible modules.

## Jenkinsfile

Testing can be automated by Jenkins.

## LICENSE

Optional license file.

## meta/main.yml

Optional meta data file for galaxy.

## Rakefile

`rake test` runs `rake test` in sub directories under `test/integration`.

## README.md

Document your role here

## tasks

The directory for all the tasks.

## tasks/main.yml

The basic structure of the file is:

```
---

- include_vars: "{{ ansible_os_family }}.yml"

- include: "install-{{ ansible_os_family }}.yml"

- include: "configure-{{ ansible_os_family }}.yml"

- name: "Do configuration ..."

```

For relatively simple applications, `configure-{{ ansible_os_family }}.yml` is
optional.

All tasks specific to the application should be defined in `tasks/main.yml`.

## tasks/install-{{ ansible_os_family }}.yml

When installing a package, the task should be here. ansible 2.x has
[package](http://docs.ansible.com/ansible/package_module.html) module that
automatically detects OS and choose appropriate package moddule for the OS.
However, often you need additional installation tasks, too, such as configuring
third-party repository, installing additional packages, etc. It is recommended
to split installation tasks into multiple files.

## `tasks/configure-{{ ansible_os_family }}.yml`

Tasks specific to a platform goes here. Examples:

`java` requires `/proc` and `/dev/fd` to be mounted. In Linux distributions,
the two files systems are mounted by default, which is not the case in BSD
platforms.  Mounting them should be defined in `configure-{{ ansible_os_family
}}.yml`
([ansible-role-java/tasks/configure-FreeBSD.yml](https://github.com/reallyenglish/ansible-role-java/blob/master/tasks/configure-FreeBSD.yml)),
not in `tasks/main.yml`.

## templates

All the templates go here.

## tests

All tests goes here. The directory has three sub directories, `serverspec` for
unit testing, `travisci` for travis CI, and `integration` for integration
tests.

## tests/serverspec

All files for unit testing go here.

## tests/serverspec/default.yml

This file is the playbook for `kitchen provision`.

## tests/serverspec/default_spec.rb

The spec file for 'default' suite in .kitchen.yml

## tests/serverspec/spec_helper.rb

The spec_helper. The default is almost always enough.

## vars/{{ ansible_os_family }}.yml

OS-specific defaults.

## Next step

Learn [Jinja2_Basics](../Jinja2_Basics).
