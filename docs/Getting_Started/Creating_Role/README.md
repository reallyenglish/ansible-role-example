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
    * [Fixed package version should be avoided](#fixed-package-version-should-be-avoided)
    * [Coding style](#coding-style)
      * [Comments](#comments)
        * [Standard comments](#standard-comments)
        * [Emphasized comments](#emphasized-comments)
        * [TODO comments](#todo-comments)
      * [YAML](#yaml)
      * [Ruby](#ruby)
  * [Directory hier](#directory-hier)
    * [defaults/main.yml](#defaultsmainyml)
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
      * [shell](#shell)
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
[qansible](https://github.com/reallyenglish/qansible) It creates all directories and
files.

## Creating a role with `qansible init`

Download and install [`qansible`](https://github.com/reallyenglish/qansible).

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

## Coding style

### Comments

#### Standard comments

A standard comment is a comment just for information, clarification and
reminder. It is not a warning, but a helpful, or casual, note for readers with
less emphasis. Standard comments should start without `XXX`, or `TODO`.

Standard comments may be removed without acknowledgement from the author, but
it is strongly recommended to confirm your understanding of the context,
solution to the issue, or the way it was fixed is correct.

```yaml
- name: Install foo
  # install ruby gem `foo`, which is not required but often useful when scripting
  gem:
    name: foo
    state: present
```

#### Emphasized comments

An emphasized comment is a comment that needs strong attention, describes
issues that takes hours to get fixed without prior knowledge, causes issues in
production when ignored, or documents (possible) bugs. An emphasized comment
must start with `XXX`.

An emphasized comment should be created when something that should be avoided
in production, that is generally NOT recommended, but used in the code.  When
code does not do the "Right Thing &copy;", it should be documented as an
emphasized comment which describes why it is not _right_ and was coded in that
way.

An emphasized comment should be documented with references, such as URLs, issue
number, line number of a commit, or PR number, if any.

Emphasized comments must be removed with acknowledgement from the author, or in
case of absent author, from other members.

Use `TODO` when the comment implies issue that needs to be fixed, instead of
`XXX`.

```yaml
- name: Restart mountd OpenBSD
  # XXX /etc/rc.d/mountd has 'rc_stop=NO'. you cannot restart it even when
  # mountd_flags has changed.
  #
  # if there is need to send a SIGTERM to mountd(8), it should be done
  # manually as there is too much involved with RPC daemons to make it
  # automagic.
  # https://github.com/openbsd/src/commit/9217ca7aa6c2a8a0f0d5bd8516dbc7273e3686d2
  shell: pkill mountd
  notify:
    - Start mountd OpenBSD
    state: present
```

#### TODO comments

A TODO comment is a comment that describes what should be done in the future.
It should start with `TODO`.

TODO comment must have a corresponding issue.

TODO  comments must be removed when and only when the corresponding issue
is closed, and with acknowledgement from the author, or in case of absent
author, from other members.

When removing a TODO comment, all the related issues must be fixed and closed.
The commit that removes TODO comment should have issue numbers of related
issues so that the issues are automatically closed (see [Closing issues via
commit messages](https://help.github.com/articles/closing-issues-via-commit-messages/)).

A TODO comment must have corresponding issue number, and should be documented
with references, such as URLs, line number of a commit, or PR number, if any.

```yaml
- set_fact:
    # TODO remove equalto.py from `test_plgins`. see #9
    rabbitmq_plugins_enable:  "{{ rabbitmq_plugins | selectattr('state', 'equalto', 'enabled')  | list }}"
```

### YAML

Use two spaces for indent.

Use `name:` always. You MAY omit it for the following modules:

* `set_fact`
* `include_vars`
* `include`
* `debug` (but it should not be committed)

In YAML, always prefer:

```yaml
- name: Install foo
  apt:
    name: foo
    state: present
```

Instead of:

```yaml
- name: Install foo
  apt: "name=foo state=present"
```

A list should be in the form of:

```yaml
foo:
  - bar
  - buz
```

Instead of:

```yaml
foo: [ bar, buz ]
```

Use one-line form only when necessary. An example:

```yaml
foo: "{% if ansible_os_family == 'OpenBSD' %}[ bar ]{% else %}[ bar, buz ]{% endif %}"
```

For dict, prefer:

```yaml
foo:
  bar: buz
```

Instead of:

```yaml
foo: { bar: buz }
```

Assign an empty list, or dict as default. An example:

```yaml
foo_dict: {}
```

Instead of:

```yaml
foo_dict:
```

### Ruby

Use the provided `.rubocop.yml`

# Directory hier

## defaults/main.yml

This file lists all the variables used in the role except variables prefixed
with`register_`, and `__`. When you add a variable to the role, always define
the variable here. It will prevents undocumented variables in `README.md` and
`AnsibleUndefinedVariable`, which should not happen unless it is an expected
behaviour.

It is strongly encouraged to provide path to PID file even when the role does
not use it in any way. An example:

```yaml
foo_pid_dir: "{{ __foo_pid_dir }}"
foo_pid_file: "{{ foo_pid_dir }}/foo.pid"

```

Users can use the variable to send signals, very useful to send `SIGHUP` in
`logrotate` script. Do not hard-code the path to PID file because PID directory
is not always `/var/run`. Provide a variable to PID directory so that users can
override it.

## extra_modules

Extra ansible modules go here.

## filter_plugins

Jinja2 filter plugins go here.

## Gemfile and Gemfile.lock

Required gems are installed by `bundler`.

## handlers/main.yml

All the handlers that are called by tasks in roles.

In most cases, you would need a `Restart foo service` handler here. Notify it
when a service needs to be restarted.

```yaml
- name: Restart foo
  service:
    name: foo
    state: restarted
```

Note that `state: restarted` means _full_ restart; the service will be stopped
and started. Some services support `reload`, reloading changes that have been
made without doing full restart. If the service supports reload, `Reload foo`
should be created. In most cases, `init.d` script, `systemd` unit file, or
`rc.subr(8)` accepts `reload` action. In that case, simply use `state:
reloaded`.

```yaml
- nameL Reload foo
  service:
    name: foo
    state: reloaded
```

Do *NOT* use `enabled: true` in a service handler. For example, the following
tasks and a handler might looks safe, but they are not.

```yaml
# in tasks/main.yml

- name: Create foo.conf
  template:
    src: foo.conf.j2
    dest: /etc/foo.conf
    notifies: Restart foo

- name: Start foo
  service:
    name: foo
    enabled: yes

# in handlers/main.yml

- name: Restart foo
  service:
    name: foo
    state: restarted
    enabled: yes
```

It would work until `arguments` is added to `Start foo`.

```yaml
# in tasks/main.yml

- name: Create foo.conf
  template:
    src: foo.conf.j2
    dest: /etc/foo.conf
    notifies: Restart foo

- name: Start foo
  service:
    name: foo
    enabled: yes
    arguments: "{{ foo_flags }}"

# in handlers/main.yml

- name: Restart foo
  service:
    name: foo
    state: restarted
    enabled: yes
```

The `arguments` changes the behaviour of the task, which breaks idempotency
test. The behaviour would have been same if the handler had `arguments` and the
same value. Before scratching your head, simply _DO NOT USE_ `enabled` in
handler.

## Jenkinsfile

Testing can be automated by Jenkins.

## LICENSE

Optional license file.

## meta/main.yml

Optional meta data file for galaxy.

## Rakefile

`rake test` runs `rake test` in sub directories under `test/integration`.

## `README.md`

Document your role here.

The first section should be the name of the role and its content
should be a description of the role. Simple description is enough.
If the role has any specific notes, warnings to users, they should
be documented.An example:

```
# ansible-role-foo

Configures foo

## Notes for users

The role would kills a kitten if used without care.
```

The description should also be set in the repository's description. You can set
the description of the repository when you create the repository or in the top
page of the Github repository.

The second section is "Requirements". Any requirements to use the role should
be documented.

"Role Variables" section should list all the variables that are
exposed to users. If a variable refers to another OS-specific
variable prefixed with `__`, the referenced variable should be
listed in a subsection. An example:

```
# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `example_foo` | an example variable | `{{ __example_foo }}` |

## FreeBSD

| Variable | Default |
|----------|---------|
| `__example_foo` | `bar` |
```

`ansible` facts (`set_fact`) used in the role MAY be documented when the facts
are only used in tasks. If a fact in the role is visible to users, such as when
the fact is used in `defaults/main.yml`,  the fact MUST be documented.

"Example Playbook" should show an example playbook. The example should always
work. To ensure the example works, update the section with the playbook for
unit test in the role.

## tasks

The directory for all the tasks.

### `shell`

When you need redirection, pipe, `if`, `while`, `&&`, or `||`, use `shell` module.

```yaml
- name: See if command output contains bar
  shell: foo | grep bar
  register: register_foo
  changed_when: false

# do something with the result
...
```

But when a variable is used, always use `quote` filter to prevent shell injection.

```yaml
- name: See if command output contains bar
  shell: "foo | grep {{ item | quote }}"
  register: register_foo
  with_items: "{{ some_list }}"
  changed_when: false
```

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

When installing a package, the task should be here. `ansible` 2.x has
[package](http://docs.ansible.com/ansible/package_module.html) module that
automatically detects OS and choose appropriate package moddule for the OS.
However, often you need additional installation tasks, too, such as configuring
third-party repository, installing additional packages, etc. It is recommended
to split installation tasks into multiple files.

In general, the package should be installed in the order from:

* the official OS distribution repository, such as official CentOS repo, and
  offcial FreeBSD ports
* semi-official repository, such as EPEL and PPA
* the official vendor's repository, hashicorp for vagrant, and elastic.co for `elasticsearch`
* Reallyenglish repository

If no package is available at above sources, create one using standard
packaging system for the platform. The package must be maintained by the
organization.

Packages must not be installed from unknown sources, or unofficial
repositories.

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
