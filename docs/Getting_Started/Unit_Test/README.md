Table of Contents
=================

  * [Table of Contents](#table-of-contents)
  * [Unit testing](#unit-testing)
    * [Components](#components)
      * [kitchen](#kitchen)
      * [VirtualBox](#virtualbox)
      * [kitchen-ansible](#kitchen-ansible)
      * [kitchen-verifier-shell](#kitchen-verifier-shell)
      * [Packer](#packer)
  * [.kitchen.yml](#kitchenyml)
  * [.kitchen.local.yml](#kitchenlocalyml)
  * [default.yml](#defaultyml)
    * [provision](#provision)
    * [Writing unit tests](#writing-unit-tests)
    * [Next step](#next-step)

# Unit testing

## Components

### `kitchen`

`kitchen` is a tool to test `chef` roles. It does the followings in the order
during the `kitchen test`.

* Creating a VM in `platforms`, using a `driver`
* Converging the VM, using a provisioner
* Verifying the VM with a verifier

It is designed to test `chef` role, but supports plugins. With the plugins
below, it can test `ansible` role.

### VirtualBox

`VirtualBox` creates VMs.

### `kitchen-ansible`

`kitchen-ansible` is a provisioner, converging the VM with `ansible`.

### `kitchen-verifier-shell`

`kitchen-verifier-shell` is a verifier, verifying the state of the VM with
arbitrary shell command.

### Packer

`Packer` is a tool to create VMs from configuration files. It is not a
requirement for unit testing but a requirement to reduce resources necessary
for unit testing. `kitchen-ansible` assumes at least two VMs for a single test.
The host to be converged and the host on which `ansible` runs. Instead of
running ansible on a VM, it is possible to run `ansible` on the host to be
converged, reducing time, disk space, and other resources.

To run `ansible` locally on the target VM, `ansible` and its dependencies must
be installed on the target. The default approach is, installing them during
bootstrapping, which, of course, takes time and resources.

The approach used here is, creating VM images with `ansible` installed.
`Packer` is used to create these images.

The image configurations are in a forked git branch, available at:
[reallyenglish/packer-templates](https://github.com/reallyenglish/packer-templates/tree/reallyenglish-master).
The diff is
[here](https://github.com/reallyenglish/packer-templates/compare/master...reallyenglish:reallyenglish-master).

# .kitchen.yml

See [.kitchen.yml](https://docs.chef.io/config_yml_kitchen.html) page on the
official site for details. `qansible` creates decent `.kitchen.yml`
with decent defaults.

`serverspec` is used to create unit tests. `kitchen` run the tests in `suites`
section in `.kitchen.yml`.

```yaml
suites:
  - name: default
    provisioner:
      name: ansible_playbook
      playbook: tests/serverspec/default.yml
    verifier:
      name: shell
      command: rspec -c -f d -I tests/serverspec tests/serverspec/default_spec.rb
```

this runs:

* read `tests/serverspec/default.yml`
* provision all nodes with the ansible configuration in `default.yml`
* run rspec

# .kitchen.local.yml

You can override some `.kitchen.yml` configurations with your own options or
even extra ruby code (both files are erb template). The default
`.kitchen.local.yml` overrides proxy settings in `.kitchen.yml` if a HTTP proxy
server is running and listening at egress address and port 8080.

# default.yml

This file is the ansible play. Replace ROLENAME with the name of your role.

```yaml
---
- hosts: localhost
  roles:
    - ROLENAME
  vars:
    var1: foo
    var2: bar

```

## provision

`kitchen converge` runs `ansible`. Any extra ansible options should go to
either `provisioner` or `platform` in `.kitchen.yml`.


## Writing unit tests

serverspec has a decent
[documentation](http://serverspec.org/resource_types.html), which is very
intuitive.

Create `tests/serverspec/default_spec.rb`. An example below tests
`/etc/resolv.conf` and its contents.

```ruby
require 'spec_helper'

case os[:family]
when 'freebsd'
  describe file('/etc/resolvconf.conf') do
    its(:content) { should match /name_servers="192\.168\.1\.2 192\.168\.1\.3 192\.168\.1\.1"/ }
  end 
end

describe file('/etc/resolv.conf') do
  case host_inventory['fqdn']
  when 'default-freebsd-103-amd64'
    its(:content) { should match /nameserver 192\.168\.1\.2\nnameserver 192\.168\.1\.3\nnameserver 192\.168\.1\.1/ }
  when 'default-openbsd-60-amd64'
    its(:content) { should match /nameserver 192\.168\.1\.2\nnameserver 192\.168\.1\.1\nnameserver 192\.168\.1\.3/ }
  else
    its(:content) { should match /nameserver 192\.168\.1\.2\nnameserver 192\.168\.1\.3\nnameserver 192\.168\.1\.1/ }
  end 
end
```

## Next step

Learn [Integration_Test](../Integration_Test).
