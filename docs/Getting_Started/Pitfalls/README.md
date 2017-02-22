Table of Contents
=================

  * [Table of Contents](#table-of-contents)
  * [Common pitfalls](#common-pitfalls)
    * [Increase memory](#increase-memory)
    * [Slow services](#slow-services)
    * [Vault](#vault)
    * [Tests on Jenkins is slow](#tests-on-jenkins-is-slow)
    * [Caching HTTP requests](#caching-http-requests)
    * [Multiple nodes in a role](#multiple-nodes-in-a-role)
    * [Escaping "_" in markdown](#escaping-_-in-markdown)
    * [Vagrant 1.8.5 and centos (possibly other OS)](#vagrant-185-and-centos-possibly-other-os)
    * ["validate" and permission](#validate-and-permission)
    * [ansible-play works fine but no group variables is applied](#ansible-play-works-fine-but-no-group-variables-is-applied)
      * [Problem](#problem)
      * [Possible mistake](#possible-mistake)
    * [You can ssh to a host but some ssh connection does not work](#you-can-ssh-to-a-host-but-some-ssh-connection-does-not-work)

# Common pitfalls

## Increase memory

Default memory allocation is usually enough. However, some programs, notably
Java programs, require 1 GB memory. Add `customize` in .kitchen.yml.

    driver:
      name: vagrant
      customize:
        memory: 1024

## Slow services

Some services start up fast but others, notably Java programs, do very slow.
You need to `sleep` in a spec. The argument of `sleep` varies but 60 sec is a
good starting point. Some require 150 sec.

## Vault

When a file contains secret information, such as password, encrypt the file
with `ansible-vault`.

    > ansible-vault create files/secret.yml

Encrypt a existing file by:

    > ansible-vault encrypt files/secret.yml

Note that copy module and lookup() in ansible 2.0 do not support encrypted
files. If you need to `copy` a encrypted file, use
[copyv](https://github.com/saygoweb/ansible-plugin-copyv). An example can be
found at:
https://github.com/reallyenglish/ansible-role-system-user/blob/master/tasks/main.yml

Note that `ansible-vault` does not support multiple passwords.

## Tests on Jenkins is slow

The slowest part of a test is when test-kitchen transfer files to VM. See
[issue 491](https://github.com/test-kitchen/test-kitchen/issues/491).
`kitchen-sync` reduces the time but it hard-codes some kitchen-specific path,
such as `/usr/bin/rsync` and breaks `kitchen provision` (first `kitchen
provision` succeeds but the second one fails).

A local branch,
[without\_full\_path\_to\_rsync](https://github.com/trombik/kitchen-sync/tree/without_full_path_to_rsync),
fixed the issue. The branch assumes that both local, where kitchen-test is
invoked, and remote VM have rsync installed. The following VM images are supported:

* [trombik/ansible-freebsd-10.3-amd64](https://atlas.hashicorp.com/trombik/boxes/ansible-freebsd-10.3-amd64)
* [trombik/ansible-openbsd-6.0-amd64](https://atlas.hashicorp.com/trombik/boxes/ansible-openbsd-6.0-amd64)
* [trombik/ansible-openbsd-5.9-amd64](https://atlas.hashicorp.com/trombik/boxes/ansible-openbsd-5.9-amd64)
* [trombik/ansible-ubuntu-14.04-amd64](https://atlas.hashicorp.com/trombik/boxes/ansible-ubuntu-14.04-amd64)
* [trombik/ansible-centos-7.2-x86_64](https://atlas.hashicorp.com/trombik/boxes/ansible-centos-7.2-x86_64)

These images has been created with packer templates found at
[packer-templates](https://github.com/reallyenglish/packer-templates/tree/reallyenglish-master).
To create a image, install [packer](https://www.packer.io/) and run

```sh
packer build $target.json
```

`$target.json` should be replaced with the target file.

[ansible-role-localtime](https://github.com/reallyenglish/ansible-role-localtime),
which just creates a symlink to zone file on 4 platforms, is a good example to
see the difference.

| transport | Clean up | Check out | bundle install | kitchen test | kitchen destroy | Notify |
|-----------|----------|-----------|----------------|--------------|-----------------|--------|
| default   |  119 ms  |   5 sec   |  2 min 29 sec  | 30 min 41 sec|      2 sec      |  30 ms |
| rsync     |  115 ms  |  13 sec   |  3 min 17 sec  |  7 min 53 sec|      2 sec      |  30 ms |

To use rsync transport:

* add the gem to Gemfile
* define rsync transport in .kitchen.yml

Add the gem to Gemfile:

    gem "kitchen-sync", '~> 2.1.1', :git => 'https://github.com/trombik/kitchen-sync.git', :branch => 'without_full_path_to_rsync'

Add the following yaml snippet to .kitchen.yml

    transport:
      name: rsync

To verify the rsync transport is actually used, look at kitchen log.

       Transferring files to <default-ansible-ubuntu-1404-amd64>
       [rsync] Time taken to upload /tmp/defa....

The log should contain "[rsync] ..." right after "Transferring files...".

The second slowest part is `bundle install`. As you cannot cache HTTPS
contents, it cannot be solved.

## Caching HTTP requests

When developing a role, you need to run multiple `kitchen test`. As it usually
downloads packages from the Internet, caching reduces time. You can run a proxy
server on your local computer and use it when it is running.  `qansible`
creates .kitchen.local.yml, which overrides .kitchen.yml.  It sets http\_proxy
and https\_proxy when a proxy server is running but do not use it if not.

You may use any proxy server but in this example, I will use `polipo`.

    > polipo logFile= daemonise=false diskCacheRoot=~/tmp/cache allowedClients='0.0.0.0/0' proxyAddress='0.0.0.0' logSyslog=false logLevel=0xff proxyPort=8080

Sometimes, upstream server does not allow caching, such as FreeBSD ftp mirrors.
You can forcibly cache contents by adding `relaxTransparency=true`.

    > polipo logFile= daemonise=false diskCacheRoot=~/tmp/cache allowedClients='0.0.0.0/0' proxyAddress='0.0.0.0' logSyslog=false logLevel=0xff proxyPort=8080 relaxTransparency=true

However, be careful its consequences. When the option is used and the source
file is modified, you will download stale files.

## Multiple nodes in a role

Sometimes, you want to test multiple nodes in a role, such as AXFR between
master DNS server and its slave. In such cases, create an integration test.
`tests/integration/example` has an example integration test.

## Escaping "\_" in markdown

The default README file has a section to describe variables used in the role.
Variables often contain "\_" and it is a PITA to escape them.

[yaml2readme](https://gist.github.com/trombik/b2df709657c08d845b1d3b3916e592d3)
can be used to create the table in README.

## Vagrant 1.8.5 and centos (possibly other OS)

When vegrant replaces the key and reconnects, authentication fails. See
[#7611](https://github.com/mitchellh/vagrant/pull/7611).

    > bundle exec kitchen test centos
    ...
    default: Inserting generated public key within guest...
    default: Removing insecure key from the guest if it's present...
    default: Key inserted! Disconnecting and reconnecting using new SSH key...
    default: Warning: Authentication failure. Retrying...
    default: Warning: Authentication failure. Retrying...
    default: Warning: Authentication failure. Retrying...
    ...
    STDERR: Timed out while waiting for the machine to boot. This means that
    Vagrant was unable to communicate with the guest machine within
    the configured ("config.vm.boot_timeout" value) time period.

Apply the patch to your vagrant or install 1.8.6 or later (not released as of
this writing).

## "validate" and permission

A template can be validated with a command before writing to the `dest`.

    - name: Create a config file
      template:
        src: template.conf.j2
        dest: /etc/example.conf
        validate: "/path/to/command --check %s"

However, some commands, such as `ipsecctl(8)`, checks permission of the given
file, location, etc. the given file to the command is located at tmp directory
and the owner and group is ansible user, usually vagrant, thus, the validation
fails.

One workaround is, creating the file and backup copy of the file, validating
the file. Here is an excerpt from
[ansible-role-isakmpd](https://github.com/reallyenglish/ansible-role-isakmpd).

```yaml
    - name: Create ipsec.conf
      template:
        src: ipsec.conf.j2
        dest: "{{ isakmpd_conf }}"
        mode: 0600
        backup: yes
      register: register_ipsec_conf
      notify:
        - Restart isakmpd

    - shell: "find /etc/ -iname '{{ isakmpd_conf }}.*@*~' -type f | sort | head -n 3 | xargs -r -n 1 rm"
      changed_when: false
      when: "{{ register_ipsec_conf.changed }}"

    - command: "ipsecctl -n -f {{ isakmpd_conf }}"
      changed_when: false
      when: "{{ register_ipsec_conf.changed }}"
```
## ansible-play works fine but no group variables is applied

### Problem

You have created a group, group\_a. But, none in group\_vars/group\_a does not
applied to the host.

### Possible mistake

The most likely mistake would be missing `children` in group definitions in
inventory file. The following is an example with the mistake.

```
# This does not work
[host_a]
host_a

[group_a]
host_a
```

```
# This works
[host_a]
host_a

[group_a:children]
host_a
```

When create a group, include `:children`. Be very careful not to.

##  You can ssh to a host but some ssh connection does not work

When an option value contains `%`, ssh(1) expands the percent and a following
character as a macro, explained in `ssh_config(5)`. To escape `%`, as in our
case, you need to replace `%` with `%%`. However, `-i` flag has a bug. Given
`-i /path/%%to%%/key`, meaning your key is located at `/path/%to%/key`, ssh(1)
says it does not exist. Given `-i /path/%to%/key`, it tries to expand it but
does not know about `%t`, resulting to an error. Thus, ansible play fails.

Use `-o IdentityFile /path/%%to%%/key`, which replaces `%%` with `%`, instead
of `-i`.

The
[diff](https://github.com/trombik/vagrant/compare/master...trombik:percent_expand)
solves the issue. You need to apply the patch to `vagrant` on Jenkins.