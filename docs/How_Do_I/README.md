# How do I?

Here is a list of _how-do-i_ questions and answers.

Table of Contents
=================

  * [How do I?](#how-do-i)
  * [Table of Contents](#table-of-contents)
    * [How do I remove sensitive information from logs?](#how-do-i-remove-sensitive-information-from-logs)
      * [Problem](#problem)
      * [Solution](#solution)
    * [How do I use a different playbook depending on platform?](#how-do-i-use-a-different-playbook-depending-on-platform)
      * [Problem](#problem-1)
      * [Solution](#solution-1)
    * [How do I compare version?](#how-do-i-compare-version)
      * [Problem](#problem-2)
      * [Solution](#solution-2)
    * [How do I retry a task?](#how-do-i-retry-a-task)
      * [Problem](#problem-3)
      * [Solution](#solution-3)
    * [How do I use a role that my role depends on?](#how-do-i-use-a-role-that-my-role-depends-on)
      * [Problem](#problem-4)
      * [Solution](#solution-4)
    * [How do I comment out in README.md?](#how-do-i-comment-out-in-readmemd)
      * [Problem](#problem-5)
      * [Solution](#solution-5)
    * [How do I change SELinux policy that restrcits a service from binding non-default port?](#how-do-i-change-selinux-policy-that-restrcits-a-service-from-binding-non-default-port)
      * [Problem](#problem-6)
      * [Solution](#solution-6)
    * [How do I create SELinux policy?](#how-do-i-create-selinux-policy)
      * [Problem](#problem-7)
      * [Solution](#solution-7)
    * [How do I test yaml or json file?](#how-do-i-test-yaml-or-json-file)
      * [Problem](#problem-8)
      * [Solution](#solution-8)
    * [How do I notify immediately after a task?](#how-do-i-notify-immediately-after-a-task)
      * [Problem](#problem-9)
      * [Solution](#solution-9)
    * [How do I run some tasks before kitchen coverage?](#how-do-i-run-some-tasks-before-kitchen-coverage)
      * [Problem](#problem-10)
      * [Solution](#solution-10)
    * [How do I create a file without template module?](#how-do-i-create-a-file-without-template-module)
      * [Problem](#problem-11)
      * [Solution](#solution-11)
    * [How do I validate X509 cert?](#how-do-i-validate-x509-cert)
      * [Problem](#problem-12)
      * [Solution](#solution-12)
    * [How do I reliably start Java applications?](#how-do-i-reliably-start-java-applications)
      * [Problem](#problem-13)
      * [Solution](#solution-13)
    * [How do I conditionally depend on other roles?](#how-do-i-conditionally-depend-on-other-roles)
      * [Problem](#problem-14)
      * [Solution](#solution-14)
    * [How do I update a Vagrant box?](#how-do-i-update-a-vagrant-box)
      * [Problem](#problem-15)
      * [Solution](#solution-15)
    * [How do I test a case that is not idempotent?](#how-do-i-test-a-case-that-is-not-idempotent)
      * [Problem](#problem-16)
      * [Solution](#solution-16)
    * [How do I manage flags for service command, /etc/sysconfig/foo and <code>/etc/default/foo</code>?](#how-do-i-manage-flags-for-service-command-etcsysconfigfoo-and-etcdefaultfoo)
      * [Problem](#problem-17)
      * [Solution](#solution-17)
    * [How do I support TLS in a role?](#how-do-i-support-tls-in-a-role)
      * [Problem](#problem-18)
      * [Solution](#solution-18)
    * [How do I retry some tests that fail randomly?](#how-do-i-retry-some-tests-that-fail-randomly)
      * [Problem](#problem-19)
      * [Solution](#solution-19)
    * [How do I enforce a variable is a certain type of object, or has necessary attributes?](#how-do-i-enforce-a-variable-is-a-certain-type-of-object-or-has-necessary-attributes)
      * [Problem](#problem-20)
      * [Solution](#solution-20)

## How do I remove sensitive information from logs?


### Problem

`ansible` task logs given inputs, such as `item`, by default even when verbose
is turned off. You have sensitive information in a dict or a list. You want to
hide it.

### Solution

Use `no_log`.

```yaml
- command: hostname
  no_log: True
```

When it's `True`, no logs are displayed.

    skipping: [localhost] => (item=(censored due to no_log))  => {"censored": "the output has been hidden due to the fact that 'no_log: true' was specified for this result"}
    changed: [localhost] => (item=(censored due to no_log)) => {"censored": "the output has been hidden due to the fact that 'no_log: true' was specified for this result"}

Obviously, when `no_log` is `True`, debugging is not possible. Set `False`
during debug.

## How do I use a different playbook depending on platform?

### Problem

You have multiple platform in `.kitchen.yml`. For some reason, you cannot use a
playbook for all platforms. You want to use different playbooks for different
platforms.

### Solution

Define two suites, create two playbooks, and use `excludes`.

```yaml
suites:
  - name: default
    provisioner:
      name: ansible_playbook
      playbook: tests/serverspec/default.yml
    verifier:
      name: shell
      command: rspec -c -f d -I tests/serverspec tests/serverspec/default_spec.rb
    excludes:
      - ubuntu-14.04-amd64
      - centos-7.2-x86_64

  - name: linux
    provisioner:
      name: ansible_playbook
      playbook: tests/serverspec/linux.yml
    verifier:
      name: shell
      command: rspec -c -f d -I tests/serverspec tests/serverspec/default_spec.rb
    excludes:
      - freebsd-10.3-amd64
      - openbsd-6.0-amd64
```

## How do I compare version?

### Problem

You want to compare version.

### Solution

Use `version_compare` filter.

```
ansible_distribution == 'Ubuntu' and ansible_distribution_version | version_compare('14.04', '<=')
```

This evaluates to true when the distribution is "Ubuntu" and the version is
less than 14.04.

## How do I retry a task?

### Problem

A task often succeeds but sometimes fails. You want to retry the task.

### Solution

Use `retries` and `until`.


```yaml
- name: Install EPEL repo.
  yum:
    name: "{{ epel_repo_url }}"
    state: present
  register: result
  until: '"failed" not in result'
  retries: 5
  delay: 10
  when: not epel_repofile_result.stat.exists
```

## How do I use a role that my role depends on?

### Problem

Your role depends on some other roles. You want use the roles in tests.

### Solution

TBW (see [qansible#issue18](https://github.com/trombik/qansible/issues/18))

## How do I comment out in README.md?

### Problem

You want to comment out some lines, leaving the lines but making them invisible
to the viewer in browser.

### Solution

Use `[//]: # (...)`.

```
[//]: # ( This is hidden )
```

## How do I change SELinux policy that restrcits a service from binding non-default port?

### Problem

Your role has a variable for users to `bind(2)` to non-default port but SELinux
policy denies it.

### Solution

Use `seport` ansible module.

```yaml
- name: Install SELinux tools
  # required when listening on non-default ports
  yum:
    name: "{{ item }}"
    state: present
  with_items:
    - libselinux-python
    - policycoreutils-python
  when: "{{ ansible_os_family == 'RedHat' }}"

- name: Configure SELinux policy (TCP)
  seport:
    ports: "{{ item }}"
    proto: tcp 
    setype: syslogd_port_t
    state: present
  with_items: "{{ rsyslog_server_config_listen_port }}"
  when: "{{ ansible_os_family == 'RedHat' }}"
```

`rsyslogd` cannot bind to ports defined in `syslogd_port_t`. Add the non-default port to `syslogd_port_t`.

## How do I create SELinux policy?

### Problem

The SELinux policy bundled with a package does not work and you cannot fix it
by modifying existing policies.

### Solution

Create your own SELinux policy. One way to do it is *allow_until_it_works*.

```
grep nsd /var/log/audit/audit.log | audit2allow -M local_nsd; \
    semodule -i local_nsd.pp; \
    systemctl start nsd.service; \
    sleep 5; \
    systemctl status nsd.service
```

Replace:

* `grep nsd` with something that matches denied log entries
* `local_nsd` with your policy name (prefix `local_` to avoid collision)
* `nsd.service` with the service name

Run the above commands until it works. `local_nsd.te` in the current directory
will look like this:

```
module local_nsd 1.0;

require {
    type tmp_t;
    type nsd_t;
    class capability net_admin;
    class file { write create open };
    class dir { write remove_name create rmdir add_name };
}

#============= nsd_t ==============

allow nsd_t self:capability net_admin;
allow nsd_t tmp_t:dir rmdir;

allow nsd_t tmp_t:dir { write remove_name create add_name };

allow nsd_t tmp_t:file create;
allow nsd_t tmp_t:file { write open };
```
At least, the file created in this way will make the service up. Fine tune the
file, if possible.

Create tasks to enable the policy.

```yaml
- name: Create a wrapper to load SELinux policy
  copy:
    src: RedHat/semodule_load_te.sh
    dest: /bin/semodule_load_te
    mode: 0755
  when: "{{ ansible_os_family == 'RedHat' }}"

- name: Configure SELinux policy (control)
  copy:
    src: files/RedHat/local_nsd.te
    dest: "{{ nsd_conf_dir }}/local_nsd.te"
    validate: "checkmodule -M -m %s"
  register: register_local_nsd_te
  when: "{{ ansible_os_family == 'RedHat' }}"

- name: Load SELinux policy (control)
  shell: "/bin/semodule_load_te {{ nsd_conf_dir }}/local_nsd.te"
  when: "{{ ansible_os_family == 'RedHat' and register_local_nsd_te.changed }}"
```

Create a script like `semodule_load_te.sh`.

```sh
#!/bin/sh

set -e

file=$1
if [ -f "${file}" ]; then
  echo "cannot find file: ${file}" >2
fi

file_name=`basename "${file}"`
module_name=`echo "${file_name}" | cut -f1 -d'.'`
dest_dir=`dirname "${file}"`

mod_file="${dest_dir}/${module_name}.mod"
pp_file="${dest_dir}/${module_name}.pp"

checkmodule -M -m -o "${mod_file}" "${file}"
semodule_package -o "${pp_file}" -m "${mod_file}"
semodule -i "${pp_file}"
```

## How do I test yaml or json file?

### Problem

You want to test the structure of a YAML file. Using regular expression makes
the spec file complicated.

### Solution

Use `its(:content_as_yaml)` or `its(:content_as_json)` available in `serverspec` version 2.37.2 and newer.

```ruby
describe file(config) do
  it { should be_file }

  # server:
  #   interface: 10.0.2.15

  its(:content_as_yaml) { should include('server' => include('interface' => '10.0.2.15')) }
end
```

## How do I `notify` immediately after a task?

### Problem

You want to `notify` a task when other task result has changed, but a handler
is called at the end of all tasks. You want to `notify` immediately after the
change. Using `meta: flush_handlers` is not an option because it runs other
handlers in the queue.

### Solution

Use `register`.

```yaml
- name: Create dhclient.conf
  template:
    src: dhclient.conf.j2
    dest: "{{ dhclient_config_file }}"
  register: register_dhclient_conf

- name: Restart dhclient
  shell: "dhclient -x && dhclient {{ dhclient_interface }}"
  when: register_dhclient_conf.changed
```
## How do I run some tasks before `kitchen coverage`?

### Problem

You want to run some tasks in a unit test before `kitchen coverage`. The tasks
would perform necessary actions for the unit test. A use case is: the role has
two functionalities, creating and destroying something, or adding and removing
a user. The test case for `creating` can be covered by a simple unit test. But
to test `removing` requires that the _something_ exists before running the unit
test.

Additionally, you do not want to break idempotency of the role, meaning the
unit test does not change anything at the second run.

### Solution

Add the tasks in `pre_tasks`. Wrap the `pre_tasks` with a flag that ensures the
`pre_tasks` to run only once. An example `tests/serverspec/default.yml` looks
like this.

```yaml
- hosts: localhost
  pre_tasks:

    - name: See if pre_tasks has been performed before
      stat:
        path: /tmp/pre_tasks
      register: register_pre_tasks
      changed_when: false

    - name: Create gre1
      service:
        name: netif
        arguments: gre1
        state: started
      changed_when: false
      when:
        - "{{ ansible_os_family == 'FreeBSD' }}"
        - "{{ not register_pre_tasks.stat.exists }}"

    - name: Create a marker that indicates pre_tasks has been performed
      file:
        path: /tmp/pre_tasks
        state: touch
      when: "{{ not register_pre_tasks.stat.exists }}"
      changed_when: false

  roles:
    - ansible-role-virtual-interface
  vars:
    virtual_interface:
```

All tasks in `pre_tasks` must have `changed_when: false`, or it breaks
idempotency.

## How do I create a file without template module?

### Problem

You want to create a file but do not want to use template module because
template module requires template files.

### Solution


Use lineinfile.

```yaml
- name: Create a new file with lineinfile
  lineinfile:
    dest: /tmp/test.conf 
    regexp: "^"
    line: "{{ content }}"
    state: present
    create: True
```

Naive approach is using `shell`. Please don't

```yaml
- command: echo "whatever" > /tmp/test.conf
```

This breaks idempotency test.

## How do I validate X509 cert?

### Problem

You want to validate a X509 cert or key.

### Solution

Use `openssl` to validate a key or a cert.

```yaml
- name: Install cert.pem
  template:
    src: cert.pem.j2
    dest: /path/to/cert.pem"
    validate: openssl x509 -noout -in %s

- name: Install key.pem
  template:
    src: key.pem.j2
    dest: /path/to/key.pem"
    validate: openssl rsa -check -noout -in %s
```
## How do I reliably start Java applications?

### Problem

Java applications are known to be Unix-unfriendly. When you starts a Java
application, the command immediately returns with exit status zero, but it
takes unpredictable time to start, even fails to start. Assuming zero exit
status means successful start leads to test failures.

### Solution

Create a handler to wait the Java application to start listening a port and
call the handler from restart, or reload, handlers.

```yaml
---

- name: restart elasticsearch
  service:
    name: elasticsearch
    state: restarted
  notify: Wait for elasticsearch to start

- name: Wait for elasticsearch to start
  wait_for:
    host: localhost
    port: "{{ elasticsearch_http_port }}"
```

The zero exit status code just means the command successfully launch a Java VM.
There is no way to know if the application has been launched successfully. This
solution only works for Java applications that listens on network interface. If
the application does not, using `path` and `search_regex` might work. See
[`wait_for`](http://docs.ansible.com/ansible/wait_for_module.html) module.

## How do I conditionally depend on other roles?

### Problem

Your role supports multiple platforms. One of platforms requires other role,
but the dependent role is specifically designed for the platform only and you
do not want to require the dependent role in other platforms.

### Solution

Conditionally require the dependent role in the playbook. Note that this is
`soft` dependency (more on later).

Suppose, a package is in the official package repositories except `RedHat`. The
upstream provides a package repository for `RedHat`. The role needs to add the
repository.

```yaml
---
- hosts: localhost
  roles:
    - role: reallyenglish.redhat-repo
      when: ansible_os_family == "RedHat"
    - ansible-role-elasticsearch
  vars:
    elasticsearch_cluster_name: testcluster
    ... other variables for elasticsearch
    redhat_repo:
      elastic_co:
        description: Elasticsearch repository for 2.x packages
        base_url: https://packages.elastic.co/elasticsearch/2.x/centos
        gpgkey: https://artifacts.elastic.co/GPG-KEY-elasticsearch
        gpgcheck: yes
        enabled: yes
```

Also, create `requiements.yml` in the role's root directory, something like:

```yaml
---
- name: reallyenglish.redhat-repo
```

Then, add `requirements_path` to provisioner section in`.kitchen.yml`.

```
---
driver:
  name: vagrant
  customize:
    memory: 1024

transport:
  name: rsync

provisioner:
  hosts: test-kitchen
  name: ansible_playbook
  require_chef_for_busser: false
  require_ruby_for_busser: false
  ansible_verbosity: 1
  ansible_verbose: true
  ansible_extra_flags: <%= ENV['ANSIBLE_EXTRA_FLAGS'] %>
  requirements_path: requirements.yml
  ... other options ...
```

If you have an integration test, you need to import the dependent roles,
probably in `Rakefile`.

Lastly, update Dependencies section in `README.yml`.

However, these conditional dependencies do not prevent `ansible` from parsing
the role. Even if `ansible_os_family` is NOT `RedHat`, the depended role must
exist. `ansible` parses the depended role at runtime, finds the conditional
does not meet, and skip tasks in the depended role. The depended role still
needs to be in `roles` directory, by `ansible-galaxy` or other means.

See a comment from a developer at [Ansible does not parse condition for
dependencies on initial scan. #14289](https://github.com/ansible/ansible/issues/14289#issuecomment-180541277).

> Roles are brought in as pre-processor statements essentially, and any
> conditionals applied to them are inherited by their tasks. Conditionals do
> not stop roles from being parsed

The above example is `soft` dependency. The other dependency is `hard`
dependency. The `soft` dependency is not necessarily a dependency of the
package being managed. `reallyenglish.redhat-repo` would have been unnecessary
if the package was in the official package repository. When the package
eventually gets included in the repository, `reallyenglish.redhat-repo` will be
removed. This is why it is called `soft` dependency. Soft dependency can be
overridden by users. Users might be able to add different yum repository by
other means. The role does not care. The only requirement is successful `yum`
task.

On the other hand, `hard` dependency is used when the role depends others no
matter what. Suppose a package is a commercial product and it will never get
included in the official repository, but only available in the vendor's
repository. Then, the dependency is `hard`. In this case, the role must add the
vendor's repository as a yum repository. You can create `hard` dependency in
`meta/main.yml`.

```yaml
---
galaxy_info:
  author: Me
  ... other information for galaxy ...
dependencies:
  - { role: reallyenglish.redhat-repo, when: ansible_os_family == "RedHat" }
```

The major difference is that, `hard` dependency cannot be removed by users. It
might not be ideal for users, users might have their own repository to provide
the package, but the role always depends on the dependent role (but in case of
the example, you may nullify the effect by not supplying any values to the
dependent role). The other difference is, the dependent role is always executed
before the depending role. In some cases, you might need different order. In
that case, it is only possible with `soft` dependency.

## How do I update a Vagrant box?

### Problem

You have an outdated Vagrant box. You want to update it.

### Solution

Create a `Vagrantfile` and run `vagrant box update`.

`vagrant` updates only boxen listed in `Vagrantfile`, however, `kitchen` does
not use `Vagrantfile`. You need to create a `Vagrantfile` by `vagrant init`.

```sh
vagrant init
vi Vagrantfile
```

Replace `base` with the name of the box you want to update.

```diff
--- Vagrantfile.orig    2016-12-26 14:24:38.978153498 +0900
+++ Vagrantfile 2016-12-26 14:26:16.323281434 +0900
@@ -12,7 +12,7 @@

   # Every Vagrant development environment requires a box. You can search for
   # boxes at https://atlas.hashicorp.com/search.
-  config.vm.box = "base"
+  config.vm.box = "trombik/ansible-ubuntu-14.04-amd64"

   # Disable automatic box update checking. If you disable this, then
   # boxes will only be checked for updates when the user runs

```

Update the box by `vagrant box update`.

```sh
vagrant box update
```

The `Vagrantfile` is no longer used. Delete the file.

```sh
rm Vagrantfile
```

TODO automate the update procedure

## How do I test a case that is not idempotent?

### Problem

Your test case would change the system being tested, but that causes test
failure in the second ansible play when `idempotency_test` is `true`, which is
our default. One of typical use case is, you would like to test tasks that add
and remove something. Testing the former case is easy. Add the thing that does
not exist in the default system, and see if it has been added in the test.
However, the latter requires you to add the thing to the default system
*before* the test, which means every ansible play changes the system.

An example:

* a task in `pre_tasks` creates `X` on the system so that the role can remove it in the play
* a task in the role removes `X`

When the test above runs with `idempotency_test: true`, the test would fail
because the task in the role always removes `X`.

### Solution

Create a test suite that tests the above scenario with `idempotency_test:
false`.

In `.kitchen.yml`, `idempotency_test` should be `true` by default.

```yaml
provisioner:
  hosts: test-kitchen
  name: ansible_playbook
  ... other defaults ...
  idempotency_test: true
```

In `suites`, override `idempotency_test`.

```yaml
suites:
  - name: default
    provisioner:
      name: ansible_playbook
      playbook: tests/serverspec/default.yml
    verifier:
      name: shell
      command: rspec -c -f d -I tests/serverspec tests/serverspec/default_spec.rb

  - name: empty_devfsrules_devfs_system_ruleset
    provisioner:
      name: ansible_playbook
      playbook: tests/serverspec/empty_devfsrules_devfs_system_ruleset.yml

      # XXX disable idempotency_test as this test always change the system
      idempotency_test: false
    verifier:
      name: shell
      command: rspec -c -f d -I tests/serverspec tests/serverspec/empty_devfsrules_devfs_system_ruleset_spec.rb
```

Create tasks in `pre_tasks` that add something. Note that the tasks in
`pre_tasks` should have `changed_when: false` because you would like to know
only the number of changes that the role has made to the system.

```yaml
- hosts: localhost
  pre_tasks:
    # test if the role removes devfs_system_ruleset from rc.conf(5) when
    # devfsrules_devfs_system_ruleset is ""
    - shell: "echo devfs_system_ruleset=foo | sudo tee -a /etc/rc.conf"
      changed_when: false
    - command: "grep devfs_system_ruleset /etc/rc.conf"
      changed_when: false
  roles:
    - ansible-role-devfsrules
  vars:
    devfsrules:
      - name: devfsrules_jail_with_bpf
        number: 100
        rules: |
          add include $devfsrules_hide_all
          add include $devfsrules_unhide_basic
          add include $devfsrules_unhide_login
          add path 'bpf*' unhide
          add path 'net*' unhide
          add path 'tun*' unhide
      - name: my_rule
        number: 999
        rules: |
          add path 'tun*' hide
          # choose a device that exists in the VM and is safe to hide
          add path led/em0 hide
          add path 'bpf' user root
          add path 'bpf' group network
          add path 'bpf' mode 660
```

## How do I manage flags for service command, `/etc/sysconfig/foo` and `/etc/default/foo`?

### Problem

Often, a service provides a way to specify additional command line flags for
the service command. Different platform has a different mechanism to manage the
flags, some even provides extra variables under `/etc/sysconfig` for
RedHat-variants, `/etc/default` for Debian-variants, and `/etc/rc.conf.d` for
FreeBSD. OpenBSD has a similar mechanism, but uses a single file,
`/etc/rc.conf.local`.

### Solution

Define `foo_flags` and `foo_flags_default` in `defalts/main.yml`. `foo_flags`
is a dict for users to change the default, and `foo_flags_default` is a dict
that contains platform's default variables and values. Merge them into
`foo_flags_merged` so that `foo_flags` is combined with `foo_flags_default` as
early as possible in `tasks/main.yml`. Use `foo_flags_merged` in the template.

```yaml
# defaults/main.yml

# this variable must be an empty dict by default. do not surprise users by
# changing default behaviour.
foo_flags: {}
foo_flags_default: "{{ __foo_flags_default }}"
```

```yaml
# vars/RedHat.yml
__foo_flags:
    # XXX make sure keys and values defined here are same in the default
    # installation, and the created file does not change the default behaviour
    # when `foo_flags` is an empty dict, i.e. default.
    VAR1: VALUE1
    VAR2: VALUE2
```

```yaml
# vars/OpenBSD.yml
__foo_flags:
    # XXX for OpenBSD, the variable should have a single key, `flags`, with its
    # value set to empty string.
    flags: ""
```

```yaml
# tasks/main.yml

- include_vars: "{{ ansible_os_family }}.yml"

- set_fact:
    # more often than not, users want to modify a single value in the file.
    # providing deafult variable and using `combine()` gives two benefits:
    #
    # * users do not have to specify all other default values they do not care
    # * even when the defaults in the role are outdated, users can workaround
    #   the issue by overriding foo_flags_default
    foo_flags_merged: "{{ foo_flags_default | combine(foo_flags) }}"

- include: "configure-{{ ansible_os_family }}.yml"

- name: Start foo
  service:
    # XXX do not use `enable` here
    name: foo
    state: started
```

```yaml
# tasks/configure-RedHat.yml
- name: Create /etc/sysconfig/foo
  template:
    src: RedHat.sysconfig.j2
    dest: /etc/sysconfig/foo
    # create a backup file for reference
    backup: yes 
    validate: sh -n %s
  notify: Restart foo

- name: Enable foo
  service:
    name: "{{ foo_service }}"
    enabled: yes
```

```yaml
# tasks/configure-OpenBSD.yml
- name: Enable foo
  service:
    name: "{{ foo_service }}"
    enabled: yes 
    arguments: "{{ foo_flags_merged.flags }}"
```

```html+jinja
# templates/RedHat.sysconfig.j2, Debian.default.j2 and FreeBSD.rc.d.j2
{% for k, v in foo_flags_merged | dictsort() %}
{{ k }}="{{ v }}"
{% endfor %}
```

```
# README.md

## `foo_flags`

This variable is a dict of variables of startup configuration files, such as
files under `/etc/default`, `/etc/sysconfig`, and `/etc/rc.conf.d`. It is
assumed that the files are `source`d by startup mechanism with `sh(1)`. A key
in the dict is name of the variable in the file, and the value of the key is
value of the variable. The variable is combined with a variable whose name is
same as this variable, but postfixed with `_default` (explained below) and the
result creates the startup configuration file, usually a file consisting of
lines of `key="value"` under appropriate directory for the platform.

When the platform is OpenBSD, the above explanation does not apply. In this
case, the only valid key is `flags` and the value of it is passed to
`daemon_flags` described in [`rc.conf(5)`](http://man.openbsd.org/rc.conf),
where `daemon` is the name of one of the `rc.d(8)` daemon control scripts.

## `foo_flags_default`

This variable is a dict of keys and values derived from upstream's default
configuration, and is supposed to be a constant unless absolutely necessary. By
default, the role creates a startup configuration file for each platform with
this variable, identical to default one.

When the platform is OpenBSD, the variable has a single key, `flags` and its
value is empty string.
```

Some important things to note:

* Explicitly `enable` the service in `configure-RedHat.yml`. Due to a bug (IMO)
  in `ansible`, the service module modifies command line flags in OpenBSD.
* Some _broken_ startup scripts encourage users to add additional commands,
  such as `ulimit`, in the templated files. When this is the case, you need to
  come up with a special key in `foo_flags` and handle the case in the
  templates.
* When testing `/etc/rc.conf.local` in unit test for OpenBSD, remember that,
  when  default `foo_flags`is set in `/etc/rc.d/foo` _AND_ the `arguments` value
  given to service module are same, `foo_flags` in `/etc/rc.conf.local` is set
  to null, i.e. `foo_flags=`. Always set non-default value in the test suite.

## How do I support TLS in a role?

### Problem

The application managed by the role supports TLS. Implementing certificate
management looks re-inventing the wheel. How do I support TLS easily?

### Solution

Use
[`reallyenglish.x509-certificate`](https://github.com/reallyenglish/ansible-role-x509-certificate).

Add a button to enable TLS support to `defaults/main.yml`. The default should
be `no`.

```yaml
# defaults/main.yml
foo_include_role_x509_certificate: no
```

Create `include` task in `tasks/main.yml` after installing the package because
you would need to set permissions on certificate files and the user must exist
before `reallyenglish.x509-certificate` is executed.

Including task file like this is  unnecessary if you do not support older
`ansible` version than 2.2, in which `include_role` was implemented. But if you
do, `include` is needed. Otherwise, as older `ansible` does not know
`include_role`, it would raise an error.

```yaml
# tasks/main.yml
- include: "x509.yml"
  when:
    - ansible_version.full | version_compare('2.2', '>=')
    - foo_include_role_x509_certificate
```

In `tasks/x509.yml`, include `reallyenglish.x509-certificate` with
`include_role`.

```yaml
# tasks/x509.yml

# XXX this task should have been in `tasks/main.yml` but ansible older than 2.2
# does not understand `include_role` and bails out.
- name: Include x509-certificate
  include_role:
    name: reallyenglish.x509-certificate
```

To include `reallyenglish.x509-certificate`, the role must be there. This is
not a _regular_ dependency, and you MUST NOT add a dependency on
`reallyenglish.x509-certificate` to `meta/main.yml`.

```yaml
# requirements.yml
- name: reallyenglish.x509-certificate
```

Lastly, update `README.md`.

```
# README.md

## `foo_include_role_x509_certificate`

When `yes`, the role includes and executes
[`reallyenglish.x509`](https://github.com/reallyenglish/ansible-role-x509-certificate)
during the play, which makes it possible to manage certificates without ugly
hacks. This is only supported in `ansible` version _at least_ 2.2 and later.
```

Why not make the role depend on `reallyenglish.x509-certificate`? Because
dependency (or requiring a role in roles) in `meta/main.yml` forces the
dependent role to be executed before the depending role. While the private key
is almost always owned by a user or a group, but they do not exist yet because the
user or the group is not created yet. Creating the key pair after initial play
is possible but not when you need TLS enabled from the beginning because the
key pair needs to be in place with correct owner, group and permission in the
middle of the play.

There was a bug in `ansible`, which causes the included role skipped. See issue
[25136](https://github.com/ansible/ansible/issues/25136). In short, if the
depending role has hard-dependency in `meta/main.yml` with conditional, such as
`when: ansible_os_family == 'RedHat'`, the included role is skipped when the
conditional is not met. This was fixed in
[495a809f](https://github.com/ansible/ansible/commit/495a809f469dcb19f27d61993554b80c7bf79e9b).
If the role has a hard-dependency and cannot remove it, you cannot use this
solution.

## How do I retry some tests that fail randomly?

### Problem

Some tests fail initially, only succeed after some delays. How do I retry such tests?

### Solution

Use [`rspec-retry`](https://github.com/NoRedInk/rspec-retry).

Add `rspec-retry` to `Gemfile` (note that version could be different).

```ruby
gem "rspec-retry", "~> 0.5.5"
```

In `spec_helper`:

```ruby
require "rspec/retry"

# optionally, be verbose
RSpec.configure do |config|
  config.verbose_retry = true
  config.display_try_failure_messages = true
end
```

In spec files:

```ruby
describe server(:server1) do
  it "does something", retry: 10, retry_wait: 10 do
  # your test goes here
  end
end
```

`retry` and `retry_wait` depend on various factors. Identify optimal values by
trial and error.

## How do I enforce a variable is a certain type of object, or has necessary attributes?

### Problem

Some tasks assume that a variable is a dict with a set of mandatory attributes
set, a list, or string. Instead of bailing out with `ansible` error during
play, you would like to validate the variable as early as possible.

### Solution

Use `assert` module. The following example illustrates how a user-provided list
of dict can be validated.

```yaml
- include_vars: "{{ ansible_os_family }}.yml"

- assert:
    msg: monit_conf_extra_include_dir must be sequence, or list
    that:
      - monit_conf_extra_include_dir is sequence

- assert:
    msg: "`path` of item in monit_conf_extra_include_dir must exist and must be string"
    that:
      - "'path' in item"
      - item.path is string

  with_items: "{{ monit_conf_extra_include_dir }}"
- assert:
    msg: "`state` of item in monit_conf_extra_include_dir must exist and must be either `enabled` or `disabled`"
    that:
      - "'state' in item"
      - item.state == 'enabled' or item.state == 'disabled'
  with_items: "{{ monit_conf_extra_include_dir }}"

- assert:
    msg: item in monit_conf_extra_include_dir must have `path`, `mode`, `owner`, and `group` as key when `state` is enabled
    that:
      - "'path' in item"
      - "'mode' in item"
      - "'owner' in item"
      - "'group' in item"
  when:
    - item.state == 'enabled'
  with_items: "{{ monit_conf_extra_include_dir }}"
```

Note that the validation part is right after the `include_vars`, which is the
earliest place where you can warn users.

`assert` should be used not only when you validate user-defined variables but
when you do complex variable operations in roles.  `assert` can assert on
variables, which cannot be accomplished by unit or integration tests.
