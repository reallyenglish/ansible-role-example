# ansible-role-example

# Introduction

In this example role, you will learn how to write a role, test cases and run them.

# Requirements

* Vagrant
* Virtualbox (>= 5.0.x, 4.x might work but the virtual box plugin on the VM box is version 5.0.x)
* Ansible (>= 2.0.x)
* bundler
* git

Install all the requied packages by following the instructions below.

| Name | Install instruction | Confirmed version |
|------|---------------------|-------------------|
| Vagrant | https://www.vagrantup.com/docs/installation/ | 1.8.5 |
| Virtualbox | https://www.virtualbox.org/manual/ch02.html | 5.0.14 |
| ansible | http://docs.ansible.com/ansible/intro_installation.html | 2.1.0.0 (versions, 2.1.2.0 later, have a critical bug see [issue17770](https://github.com/ansible/ansible/issues/17770) )  |
| bundler | http://bundler.io/v1.12/#getting-started | 1.12.5 |
| git | https://git-scm.com/book/en/v2/Getting-Started-Installing-Git | 2.5.0 |

# Installing ansible from a git repo

See [Running From Source](http://docs.ansible.com/ansible/intro_installation.html#running-from-source).

## Installing a specific version of ansible from git repo

If you need a specific version of `ansible`, follow the steps below.

### Installing dependencies

```sh
easy_install pip
pip install paramiko PyYAML Jinja2 httplib2 six
```

### Cloning the repo and setup

```sh
git clone git://github.com/ansible/ansible.git --recursive
cd ansible
git checkout tags/v2.1.0.0-1 -b v2.1.0.0-1
git submodule update
source hacking/env-setup
```

See the version.

```sh
ansible --version
ansible 2.1.0.0 (v2.1.0.0-1 b599477242) last updated 2016/10/03 15:27:32 (GMT +900)
  lib/ansible/modules/core: (detached HEAD e4c5a13a7a) last updated 2016/10/03 15:21:51 (GMT +900)
  lib/ansible/modules/extras: (detached HEAD df35d324d6) last updated 2016/10/03 15:22:41 (GMT +900)
  config file = /etc/ansible/ansible.cfg
  configured module search path = Default w/o overrides
```

# Learn ansible

See wiki page [Getting_Started](../../wiki/Getting_Started).

# Resources

* [Ansible modules](http://docs.ansible.com/ansible/modules_by_category.html)
* [Ansible best practices](http://docs.ansible.com/ansible/playbooks_best_practices.html)
* [serverspec resources](http://serverspec.org/resource_types.html)
* [Shared Ansible Options (vagrant options for ansible)](https://www.vagrantup.com/docs/provisioning/ansible_common.html#verbose)
* [test-kitchen](https://github.com/test-kitchen/test-kitchen)
* [kitchen-ansible](https://github.com/neillturner/kitchen-ansible)
* [Template Designer Documentation (template language)](http://jinja.pocoo.org/docs/dev/templates/)
* [ansible-filter-plugins (filters)](https://github.com/lxhunter/ansible-filter-plugins)
* [Multistage environment with Ansible (how to handle production and staging)](http://rosstuck.com/multistage-environments-with-ansible/)
# Requirements

None

# Role Variables

| variable | description | default |
|----------|-------------|---------|


# Dependencies

None

# Example Playbook


# License

Copyright (c) 2016 Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

# Author Information

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

This README was created by [ansible-role-init](https://gist.github.com/trombik/d01e280f02c78618429e334d8e4995c0)
