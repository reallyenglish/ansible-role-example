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
    * [Embedded tests in tasks](#embedded-tests-in-tasks)
    * [Next step](#next-step)

# Unit testing

## Components

### `kitchen`

[`kitchen`](https://github.com/test-kitchen/test-kitchen) is a tool to test
`chef` roles. It does the followings in the order during the `kitchen test`.

* Creating a VM in `platforms`, using a `driver`
* Converging the VM, using a provisioner
* Verifying the VM with a verifier

It is designed to test `chef` role, but supports plugins. With the plugins
below, it can test `ansible` role.

### VirtualBox

`VirtualBox` creates VMs.

### `kitchen-ansible`

[`kitchen-ansible`](https://github.com/neillturner/kitchen-ansible) is a
provisioner, converging the VM with `ansible`.

### `kitchen-verifier-shell`

[`kitchen-verifier-shell`](https://github.com/higanworks/kitchen-verifier-shell)
is a verifier, verifying the state of the VM with arbitrary shell command.

### Packer

[`Packer`](https://www.packer.io/) is a tool to create VMs from configuration
files. It is not a requirement for unit testing but a requirement to reduce
resources necessary for unit testing. `kitchen-ansible` assumes at least two
VMs for a single test.  The host to be converged and the host on which
`ansible` runs. Instead of running ansible on a VM, it is possible to run
`ansible` on the host to be converged, reducing time, disk space, and other
resources.

To run `ansible` locally on the target VM, `ansible` and its dependencies must
be installed on the target. The default approach is, installing them during
bootstrapping, which, of course, takes time and resources.

The approach used here is, creating VM images with `ansible` installed.
`Packer` is used to create these images.

The image configurations are in a forked git branch, available at:
[reallyenglish/packer-templates](https://github.com/reallyenglish/packer-templates/tree/reallyenglish-master).
The diff is
[here](https://github.com/reallyenglish/packer-templates/compare/master...reallyenglish:reallyenglish-master).

## .kitchen.yml

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

## .kitchen.local.yml

You can override some `.kitchen.yml` configurations with your own options or
even extra ruby code (both files are erb template). The default
`.kitchen.local.yml` overrides proxy settings in `.kitchen.yml` if a HTTP proxy
server is running and listening at egress address and port 8080.

## default.yml

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
require "spec_helper"

case os[:family]
when "freebsd"
  describe file("/etc/resolvconf.conf") do
    it { should be_file }
    it { should be_owned_by "root" }
    it { should be_grouped_into "wheel" }
    it { should be_mode 644 }
    its(:content) { should match(/name_servers="192\.168\.1\.2 192\.168\.1\.3 192\.168\.1\.1"/) }
  end 
end

describe file("/etc/resolv.conf") do
  it { should be_file }
  it { should be_owned_by "root" }
  it { should be_grouped_into "wheel" }
  it { should be_mode 644 }
  case host_inventory["fqdn"]
  when "default-freebsd-103-amd64"
    its(:content) { should match(/nameserver 192\.168\.1\.2\nnameserver 192\.168\.1\.3\nnameserver 192\.168\.1\.1/) }
  when 'default-openbsd-60-amd64'
    its(:content) { should match(/nameserver 192\.168\.1\.2\nnameserver 192\.168\.1\.1\nnameserver 192\.168\.1\.3/) }
  else
    its(:content) { should match(/nameserver 192\.168\.1\.2\nnameserver 192\.168\.1\.3\nnameserver 192\.168\.1\.1/)}
  end 
end
```

Even in a simple test case for a file like this, test as much as possible.
When the role might only modify the content, not file permission, or owner,
test every possible cases, like `be_file`, `be_mode`, `be_owned_by`, and
`be_grouped_into`. In case of `command`, you usually want to test
`its(:stdout)`, but the test should include `its(:stderr)`, and
`its(:exit_status)`, too.

```ruby
describe command("foo") do
  its(:stdout) { should match(/bar/) }
  its(:stderr) { should eq("") }
  its(:exit_status) { should eq 0 }
end
```

These precautions will catch your incorrect assumptions.

When writing unit tests, start one that is depended by others. For example, a
service depends on many resources, writeable directories, configuration files,
or database files. When a configuration has syntax errors, the file test, the
service test, and probably others too, would fail. If you test the service test
first, you would have to examine each failed test and figure out what actually
caused the failure. With test-depended-resources-first strategy, you would
identify the cause easily just by looking at the first failure.

Unit tests is intended to be passive. If you need to modify the state of the
target, such as adding data, do so in an integration test, which will be
explained in [Integration test](Integration_Test).

## Embedded tests in tasks

Although unit testing with `serverspec` helps role development a lot, it has a
drawback: unit tests with `serverspec` will not be executed in `ansible` play.
They are executed only when you run `kitchen test`.

Embedded tests in a role are always executed in `kitchen test`, staging
environment, or production system. As documented in the official [Testing
Strategies](http://docs.ansible.com/ansible/test_strategies.html#the-right-level-of-testing),
appropriate level of testing in tasks will help.

As the embedded tests are always executed, they should:

- be a passive test, results in zero, or minimum impact to the system
- be a generic test that covers all possible use cases
- be fast enough

## Next step

Learn [Integration_Test](../Integration_Test).
