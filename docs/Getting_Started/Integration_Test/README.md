Table of Contents
=================

h  * [Table of Contents](#table-of-contents)
  * [Integration test](#integration-test)
    * [test-kitchen vs integration test](#test-kitchen-vs-integration-test)
    * [Jenkinsfile](#jenkinsfile)
    * [Rakefile](#rakefile)
      * [Rakefile for integration tests](#rakefile-for-integration-tests)
    * [Debugging issues on a jenkins slave](#debugging-issues-on-a-jenkins-slave)
    * [everything is slow on jenkins slave](#everything-is-slow-on-jenkins-slave)
      * [Making sure same multiple VMs are not running](#making-sure-same-multiple-vms-are-not-running)
      * [Stopping and removing a VM](#stopping-and-removing-a-vm)
      * [Executing same commands in Jenkinsfile](#executing-same-commands-in-jenkinsfile)
    * [Next step](#next-step)

# Integration test

## test-kitchen vs integration test

`test-kitchen` is designed to test multiple platforms of single host in one
batch. Multiple node support has been discussed (see
https://github.com/test-kitchen/test-kitchen/issues/873), however, it is not
implemented.

`test-kitchen` is best suited to unit testing, such as testing templates,
commands and package tasks. With `kitchen` and server-spec, you can create a
role and test it within minutes.

On the other hand, with Vagrant, you can perform integration test with
multiple hosts. However, it is not easy to run an integration test that perform
the same test against multiple platforms. With some tricks with Vagrantfile, it
might be possible but the possibility is not explored yet.

Virtualbox allows arbitrary networking. It is possible to create a server, NAT
gateway, and clients for complete integration tests. In integration tests, you
should focus on the behavior of the system, not details of configuration files.

## Jenkinsfile

If the name of a repository starts with "ansible-role" and Jenkinsfile is found
in the root of the repository, Jenkins pull the repository and run Jenkinsfile.

```groovy
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
    try {
        sh "bundle install --path ${env.JENKINS_HOME}/vendor/bundle"
    } catch (e) {
        currentBuild.result = 'FAILURE'
        notifyBuild(currentBuild.result)
        throw e
    }

    stage 'bundle exec kitchen test'
    try {
      sh 'bundle exec kitchen test'
    } catch (e) {
        currentBuild.result = 'FAILURE'
        notifyBuild(currentBuild.result)
        throw e
    } finally {
      sh 'bundle exec kitchen destroy'
    }
    stage 'integration'
    try {
      // use native rake instead of bundle exec rake
      // https://github.com/docker-library/ruby/issues/73
      sh 'rake test'
    } catch (e) {
        currentBuild.result = 'FAILURE'
        notifyBuild(currentBuild.result)
        throw e
    } finally {
      sh 'rake clean'
    }

    stage 'Notify'
    notifyBuild(currentBuild.result)
    step([$class: 'GitHubCommitNotifier', resultOnFailure: 'FAILURE'])
  }
}

def notifyBuild(String buildStatus = 'STARTED') {
  // build status of null means successful
  buildStatus =  buildStatus ?: 'SUCCESSFUL'

  // Default values
  def colorName = 'RED'
  def colorCode = '#FF0000'
  def subject = "${buildStatus}: Job '${env.JOB_NAME} build #${env.BUILD_NUMBER}'"
  def summary = "${subject} <a href='${env.BUILD_URL}'>${env.BUILD_URL}</a>"
  def details = """<p>STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
    <p>Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>"""

  // Override default values based on build status
  if (buildStatus == 'STARTED') {
    color = 'YELLOW'
    colorCode = '#FFFF00'
  } else if (buildStatus == 'SUCCESSFUL') {
    color = 'GREEN'
    colorCode = '#00FF00'
  } else {
    color = 'RED'
    colorCode = '#FF0000'
  }

  hipchatSend (color: color, notify: true, message: summary)
}
```
The Jenkinsfile created by `qansible` does:

* run Jenkinsfile on a node tagged with `virtualbox`
* set ANSIBLE\_VAULT\_PASSWORD\_FILE so that it can decrypt files
* clean up the current workplace directory
* checkout the repository
* run `bundle install`
* run `bundle exec kitchen test`
* run `bundle exec kitchen destroy`
* run `rake test`
* post the build status to github and hipchat

## Rakefile

The following `Rakefile` should be in the root directory of the role.
`Rakefile` is automatically created if you bootstrap your role with
`qansible`.

```ruby
require 'pathname'

root_dir = Pathname.new(__FILE__).dirname
integration_test_dir = root_dir + 'test' + 'integration'
integration_test_dirs = Pathname.new(integration_test_dir).children.select { |c| c.directory? }

task default: %w[ test ]

desc 'run all tests'
task :test do
  integration_test_dirs.each do |d|
    rakefile = d + 'Rakefile'
    if rakefile.exist? and rakefile.file?
      Dir.chdir(d) do
        puts "entering to %s" % [ d ]
        begin
          puts 'running rake'
          sh 'rake'
        ensure
          sh 'rake clean'
        end
      end
    else
      puts 'Rakefile does not exists, skipping'
    end
  end
end

task :clean do
  integration_test_dirs.each do |d|
    rakefile = d + 'Rakefile'
    if rakefile.exist? and rakefile.file?
      Dir.chdir(d) do
        puts "entering to %s" % [ d ]
        begin
          puts 'running rake clean'
          sh 'rake clean'
        rescue Exception => e
          puts 'rake clean clean failed:'
          puts e.message
          puts e.backtrace.inspect
        end
      end
    end
  end
end
```
What it does is:

* recursively find sub-directory in test/integration.
* run `rake test` in each sub-directory.

### Rakefile for integration tests

`Rakefile` in sub-directory of tests/integration should:

* accept `test` and `clean` targets
* run tests with `test` target
* clean all the leftovers with `clean` target

An example `Rakefile` is automatically created if you bootstrap your role with
`qansible`.

## Debugging issues on a jenkins slave

This is _NOT_ how you debug your role, but how you debug issues only show up in
jenkins.


## everything is slow on jenkins slave

In our implementation, the jenkins slave is slow. Even if every spec passes on
your local machine, some could fail. You need to insert `sleep` in spec file to
wait for the VM to be stable, such as creating VPN tunnel, establishing OSPF
state, you name it.

```ruby
sleep 10 if ENV['JENKINS_HOME']
```

### Making sure same multiple VMs are not running

When same multiple VMs are running, for whatever reasons, that would create
many weired failures.

```sh
VBoxManage list runningvms
```

The command lists all running VMs.

### Stopping and removing a VM

If you would like to stop a VM, you can destroy it by:

```sh
VBoxManage controlvm $VMNAME poweroff
VBoxManage unregistervm $VMNAME --delete
```

The result is same as `kitchen destroy` or `vagrant destroy`.

### Executing same commands in `Jenkinsfile`

This is the best way to reproduce the issue you are debugging. `ssh` to the
slave and run:

```
sudo su jenkins
```

Then, `cd` to the project work space and run the commands described in
`Jenkinsfile`.

## Next step

Learn `[Extending_Ansible](../Extending_Ansible).
