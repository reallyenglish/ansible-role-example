Table of Contents
=================

  * [Table of Contents](#table-of-contents)
  * [Writing your first role](#writing-your-first-role)
    * [What your new role does](#what-your-new-role-does)
    * [Create your role](#create-your-role)
    * [Write the tests](#write-the-tests)
    * [Running the test](#running-the-test)
    * [Creating the tasks](#creating-the-tasks)
    * [Creating install-FreeBSD.yml](#creating-install-freebsdyml)
    * [Create the template](#create-the-template)
    * [Set ENV](#set-env)
    * [Running the test again](#running-the-test-again)
    * [When your test cases still fail](#when-your-test-cases-still-fail)
    * [Next step](#next-step)

# Writing your first role

## What your new role does

* install zsh
* create a file /tmp/foo, whose content is "Hello world"

## Create your role

Install [qansible](https://github.com/reallyenglish/qansible). Run:

    > qansible init ansible-role-example
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
`install-$OSNAME.yml` for each OS (2.x supports generic wrapper module for
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

## Next step

Read [Creating_Role](../Creating_Role)
