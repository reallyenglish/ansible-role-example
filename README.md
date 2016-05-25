# Introduction

In this example role, you will learn how to write a role, test cases and run them.

# Requirements

* Vagrant
* Virtualbox (>= 5.0.x, 4.x might work but the virtual box plugin on the VM box is version 5.0.x)
* Ansible (>= 2.0.x)
* bundler
* git

# Writing your first role

## What your new role does

* install zsh
* create a file /tmp/foo, whose content is "Hello world"

## Create your role

Download
[ansible-role-init.sh](https://gist.github.com/trombik/d01e280f02c78618429e334d8e4995c0)
from my gist. Put the script in your PATH. Run the script.

    > ansible-role-init ansible-role-example
    > cd ansible-role-example

The role name must start with "ansible-role-". The script creates several
files, including Gemfile, .kitchen.yml and more.

## Write the tests

    > vim spec/serverspec/default_spec.rb

    require 'spec_helper'
    require 'serverspec'

    describe package('zsh') do
      it { should be_installed }
    end 

    describe file('/tmp/foo') do
      it { should exist }
      it { should be_file }
      its(:content) { should match /Hello world/ }
    end

## Running the test

Your initial test should fail.

    > bundle exec kitchen test
    ...
    Failed examples:

    rspec ./spec/serverspec/default_spec.rb:4 # Package "zsh" should be installed
    rspec ./spec/serverspec/default_spec.rb:8 # File "/tmp/foo" should exist
    rspec ./spec/serverspec/default_spec.rb:9 # File "/tmp/foo" should be file
    rspec ./spec/serverspec/default_spec.rb:10 # File "/tmp/foo" content should match /Hello world/
    ...


## Creating the tasks

To pass the test cases, create the tasks.

    > vim tasks/main.yml

    ---
    # tasks file for ansible-role-example

    - include_vars: "{{ ansible_os_family }}.yml"

    - include: install-FreeBSD.yml
      when: ansible_os_family == 'FreeBSD'

    - name: Ensure /tmp/foo exists
      template:
        src: foo.j2
        dest: /tmp/foo
        mode: 0644

The first task includes a task file, `install-FreeBSD.yml`. ansible 1.9 does
not support module 'package'. When you install a package, you need to specify
package managers for different OS. That means you need to create
`install-$OSNAME.yml` for each OS (2.x supports genereic wrapper module for
OSes).

The second task creates the file from a template.

## Creating install-FreeBSD.yml

This task actually installs zsh.

    > vim tasks/install-FreeBSD.yml

    ---

    - name: Install zsh
      pkgng:
        name: zsh
        state: present

## Create the template

    > vim templates/foo.j2

    Hello world

## Set ENV

ansible-vault, which encrypts files, is not used in this example, but you
generally need it later. Create a secret file. Ask sysadmins for the key.

For the example, the content of the file does not matter. You may proceed with
whatever key in the file.

    > touch ~/.ansible_vault_key 
    > chmod 600 ~/.ansible_vault_key
    > vim ~/.ansible_vault_key
    > export ANSIBLE_VAULT_PASSWORD_FILE=~/.ansible_vault_key

Running the test again
----------------------

You now have the tasks. See if the test cases pass.

    > bundle exec kitchen test

    ...
    Package "zsh"
      should be installed

    File "/tmp/foo"
      should exist
      should be file
      content
        should match /Hello world/

    Finished in 0.79573 seconds (files took 0.21007 seconds to load)
    4 examples, 0 failures

    zlib(finalizer): the stream was freed prematurely.
           Finished verifying <default-freebsd-102-amd64> (0m1.20s).
    -----> Destroying <default-freebsd-102-amd64>...
           ==> default: Forcing shutdown of VM...
           ==> default: Destroying VM and associated drives...
           Vagrant instance <default-freebsd-102-amd64> destroyed.
           Finished destroying <default-freebsd-102-amd64> (0m2.97s).
           Finished testing <default-freebsd-102-amd64> (1m14.41s).
    -----> Kitchen is finished. (1m14.47s)

Now your tests passed.

## When your test cases still fail

Inspect the VM by logging in.

    > bundle exec kitchen login

## Jenkins file

If the name of a repository starts with "ansible-role" and Jenkinsfile is found
in the root of the repository, Jenkins pull the repository and run Jenkinsfile.

    node ('virtualbox') {
      def directory = "ansible-role-example"
      env.ANSIBLE_VAULT_PASSWORD_FILE = "~/.ansible_vault_key"
      stage 'Clean up'
      deleteDir()

      stage 'Checkout'
      sh "mkdir $directory"
      dir("$directory") {
        checkout scm
      }
      dir("$directory") {
        stage 'bundle'
        sh 'bundle install --path vendor/bundle'

        stage 'bundle exec kitchen test'
        try {
          sh 'bundle exec kitchen test'
        } finally {
          sh 'bundle exec kitchen destroy'
        }

        stage 'Notify'
        step([$class: 'GitHubCommitNotifier', resultOnFailure: 'FAILURE'])
      }
    }

The Jenkinsfile created by ansible-role-init does:

* run Jenkinsfile on a node tagged with `virtualbox`
* set ANSIBLE\_VAULT\_PASSWORD\_FILE so that it can decrypt files
* clean up the current workplace directory
* checkout the repository
* run `bundle install`
* run `bundle exec kitchen test`
* run `bundle exec kitchen destroy`
* post the build status to github

# Common tasks and rules

## Public or private repository

Make the repository private when:

* the role contains secret information, such as password, employee's name

Make the repository publi when:

* the role does not contain secret information

Usually, your role should be reusable, meaning it should not contain project
specific information. Make your role generic.

## Workflow

* Create a feature branch
* Change the code
* Make sure `bundle exec kitchen test` passes on your local computer
* `git push` the branch
* Make sure the tests pass on Jenkins
* Create a pull request
* Optionally ask someone in your team to review
* Merge the branch into master
* Make sure all tests in master pass on Jenkins

## ACL

When creating a repository, assign ACL

| Team | ACL |
|------|-----|
| Developer | Write |
| SysAdmins | Admin |

If you want others to see the repo, assign the following ACL

| Team | ACL |
|------|-----|
| Read and Pull | Read |

## Lisence

Prefer BSD license. `ansible-role-init` create the license by default.

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

Note that copy module and lookup() in ansible 2.0 do not suport encrypted
files. If you need to `copy` a encrypted file, use
[copyv](https://github.com/saygoweb/ansible-plugin-copyv). An example can be
found at:
https://github.com/reallyenglish/ansible-role-system-user/blob/master/tasks/main.yml

Note that `ansible-vault` does not support multiple passwords.

Resources
=========

* [Ansible modules](http://docs.ansible.com/ansible/modules_by_category.html)
* [Ansible best practices](http://docs.ansible.com/ansible/playbooks_best_practices.html)
* [serverspec resources](http://serverspec.org/resource_types.html)
* [Shared Ansible Options (vagrant options for ansible)](https://www.vagrantup.com/docs/provisioning/ansible_common.html#verbose)
* [test-kitchen](https://github.com/test-kitchen/test-kitchen)
* [kitchen-ansible](https://github.com/neillturner/kitchen-ansible)
* [Template Designer Documentation (template language)](http://jinja.pocoo.org/docs/dev/templates/)
* [ansible-filter-plugins (filters)](https://github.com/lxhunter/ansible-filter-plugins)
* [Multistage environment with Ansible (how to handle production and staging)](http://rosstuck.com/multistage-environments-with-ansible/)
