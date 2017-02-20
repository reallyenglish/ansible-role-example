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

Conditionally require the dependent role in the playbook.

```yaml
---
- hosts: localhost
  roles:
    - { role: reallyenglish.redhat-repo, when: ansible_os_family == "RedHat" }
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

You can do the same thing in `meta/main.yml` like:

```yaml
---
galaxy_info:
  author: Me
  ... other information for galaxy ...
dependencies:
  - { role: reallyenglish.redhat-repo, when: ansible_os_family == "RedHat" }
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
