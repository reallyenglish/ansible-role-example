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

Resources
=========

* Ansible modules http://docs.ansible.com/ansible/modules_by_category.html
* Ansible best practices http://docs.ansible.com/ansible/playbooks_best_practices.html
* serverspec resources http://serverspec.org/resource_types.html
* Shared Ansible Options (vagrant options for ansible) https://www.vagrantup.com/docs/provisioning/ansible_common.html#verbose
* test-kitchen https://github.com/test-kitchen/test-kitchen
* kitchen-ansible https://github.com/neillturner/kitchen-ansible
* Template Designer Documentation (template language) http://jinja.pocoo.org/docs/dev/templates/
* ansible-filter-plugins (filters) https://github.com/lxhunter/ansible-filter-plugins
* Multistage environment with Ansible (how to handle production and staging)  http://rosstuck.com/multistage-environments-with-ansible/
