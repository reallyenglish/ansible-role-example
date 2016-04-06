Introduction
============

In this example role, you will learn how to write a role, test cases and run them.

Requirements
============

* Vagrant
* Virtualbox (>= 5.0.x, 4.x might work but the virtual box plugin on the VM box is version 5.0.x)
* Ansible (>= 1.8.x)

Writing your first role
=======================

What your new role does
-----------------------

* install zsh
* create a file /tmp/foo, whose content is "Hello world"

Create your test
----------------

Create a root directory for all your roles because your roles require same set of rubygems. By creating roles under the directory, you will save the number of `bundle install`.

    > mkdir galaxy
    > cd galaxy

Create Gemfile.

    > vim Gemfile

    source 'https://rubygems.org'
    
    gem 'rspec', '~> 3.4.0'
    gem "test-kitchen", '~> 1.6.0'
    gem "kitchen-vagrant", '~> 0.19.0'
    # use patched kitchen-ansible
    gem "kitchen-ansible", '~> 0.40.1', :git => 'https://github.com/trombik/kitchen-ansible.git', :branch => 'freebsd_support'
    gem 'kitchen-verifier-shell', '~> 0.2.0'
    gem 'kitchen-verifier-serverspec', '~> 0.3.0'
    gem 'infrataster', '~> 0.3.2'
    gem 'serverspec', '~> 2.31.0'

Note that versions are reference only and you might need to use newer versions.

Install gems.

    > bundler install --path vendor

Create your role.

    > ansible-galaxy init ansible-role-example
    > cd ansible-role-example

`ansible-galaxy init` creates basic hier for a role. Create additional directories as we will use serverspec for the test framework.

    > mkdir -p spec/serverspec test/integration

Create an ansible playbook for the unit test. ansible-playbook is the playbook of the test environment.

    > vim test/integration/default.yml

    - hosts: all
      roles:
        - ansible-role-example

Create a spec\_helper.rb.

    > vim spec/serverspec/spec_helper.rb

    require 'serverspec'
    
    set :backend, :ssh
    
    options = Net::SSH::Config.for(host)
    options[:host_name] = ENV['KITCHEN_HOSTNAME']
    options[:user]      = ENV['KITCHEN_USERNAME']
    options[:port]      = ENV['KITCHEN_PORT']
    options[:keys]      = ENV['KITCHEN_SSH_KEY']

    set :host,        options[:host_name]
    set :ssh_options, options
    set :env, :LANG => 'C', :LC_ALL => 'C'

Create the spec.

    > vim spec/serverspec/default_spec.rb

    require 'spec_helper'
    
    describe package('zsh') do
      it { should be_installed }
    end 
    
    describe file('/tmp/foo') do
      it { should exist }
      it { should be_file }
      its(:content) { should match /Hello world/ }
    end

Create the VM configuration for the unit test.

    > vim .kitchen.yml

    ---
    driver:
      name: vagrant

    provisioner:
      hosts: test-kitchen
      name: ansible_playbook
      require_chef_for_busser: false
      require_ruby_for_busser: false
      ansible_verbosity: 3
      ansible_verbose: true

    platforms:
      - name: freebsd-10.2-amd64
        driver:
          box: trombik/test-freebsd-10.2-amd64
          box_check_update: false
        driver_config:
          ssh:
            shell: '/bin/sh'

    suites:
      - name: default
        provisioner:
          name: ansible_playbook
          playbook: test/integration/default.yml
        verifier:
          name: shell
          command: rspec -c -f d -I spec/serverspec spec/serverspec/default_spec.rb


Here, one FreeBSD guest is defined. The guest will be provisioned by ansible. The playbook for the provisioning is `test/integration/default.yml`. The unit test is `spec/serverspec/default_spec.rb`.

Running the test
----------------

Your initial test should fail.

    > bundle kitchen test
    ...
    Failed examples:

    rspec ./spec/serverspec/default_spec.rb:4 # Package "zsh" should be installed
    rspec ./spec/serverspec/default_spec.rb:8 # File "/tmp/foo" should exist
    rspec ./spec/serverspec/default_spec.rb:9 # File "/tmp/foo" should be file
    rspec ./spec/serverspec/default_spec.rb:10 # File "/tmp/foo" content should match /Hello world/
    ...


Creating the tasks
---------------------

To pass the test cases, create the tasks.

    > vim tasks/main.yml

    ---
    # tasks file for ansible-role-example

    - name: Include OS specific install task
      include: install-FreeBSD.yml
      when: ansible_os_family == 'FreeBSD'

    - name: Ensure /tmp/foo exists
      template: dest='/tmp/foo' src='foo.j2' mode=0644

The first task includes a task file, `install-FreeBSD.yml`. ansible 1.9 does not support module 'package'. When you install a package, you need to specify package managers for different OS. That means you need to create `install-$OSNAME.yml` for each OS (2.x supports genereic wrapper module for OSes).

The second task creates the file from a template.

Creating install-FreeBSD.yml
----------------------------

This task actually installs zsh.

    > vim tasks/install-FreeBSD.yml

    ---
    - name: Ensure zsh is installed
      pkgng: name='zsh' state='present'

Create the template
-------------------

    > vim templates/foo.j2

    Hello world


Running the test again
----------------------

You now have the tasks. See if the test cases pass.

    > bundle kitchen test

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

When your test cases still fail
===============================

Inspect the VM by logging in.

    > bundle exec kitchen login

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
