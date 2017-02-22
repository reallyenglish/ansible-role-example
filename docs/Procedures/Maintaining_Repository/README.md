Table of Contents
=================

  * [Table of Contents](#table-of-contents)
  * [Maintaining repositories](#maintaining-repositories)
    * [Creating a repository](#creating-a-repository)
      * [Creating an empty repository](#creating-an-empty-repository)
    * [Configuring the repository](#configuring-the-repository)
      * [Assigning default ACL](#assigning-default-acl)
      * [Assigning non-default ACL](#assigning-non-default-acl)
      * [Enabling automatic tests](#enabling-automatic-tests)
      * [Protecting master branch](#protecting-master-branch)
    * [Managing branches](#managing-branches)
      * [Fix branch](#fix-branch)
      * [Release branch](#release-branch)
      * [Feature branch](#feature-branch)
    * [Creating a PR](#creating-a-pr)
    * [Reviewing a PR](#reviewing-a-pr)
    * [Merging a branch](#merging-a-branch)
      * [Additional advice for reviewer](#additional-advice-for-reviewer)

# Maintaining repositories

## Creating a repository

### Creating an empty repository

All `ansible-role` repositories should be created in `reallyenglish` organization. Visit
[the organization page](https://github.com/reallyenglish) and click `New` to
create a repository.

Name your role. The name should be prefixed with `ansible-role-`. The name
should be short. It is usually the name of the package the role manages. Choose
a common denominator in distributions. Your role should manage a package, not
multiple packages. Use the package name as the repository name.

The initial state of the newly created repository should be empty. 

* Choose `reallyenglish` as owner (default)
* Fill repository name in `Repository name`
* Describe the role in `Description` (a short one, such as "Install and configure foo")
* Choose public or private repository (usually `Public`, see how to choose at
  [Public or private repository](../../Policy.md#public-or-private-repository)
* Make sure that `Initialize this repository with a README` is NOT selected (default)
* Click `Create repository` to create one

Push your loocal repository to Github by following the instructions shown in
the next page.

Proceed to [Configuring the repository](#configuring-the-repository).

## Configuring the repository

### Assigning default ACL

After creating a repository, assign ACL.

| Team | ACL |
|------|-----|
| SysAdmins | Admin |

### Assigning non-default ACL

TBW

### Enabling automatic tests

The following tests must be enabled.

* Jenkins
* Travis CI

You do not need to enable Jenkins in the repository settings. Jenkins
continuously scans the repositories prefixed with `ansible-role-` and builds
the repository if the repository has `Jenkinsfile` in the top level directory.
Make sure that the file exists.

To enable Travis CI, follow the steps below:

* Click [Settings]
* Click [Integrations & services]
* Click [Add service] and select [Travis CI]

### Protecting master branch

The `master` branch must be protected. This has a con; even when your change is
updating a line in `README.md`, you need to run complete tests. However, by
enforcing tests before merging, it ensures that the tests passes anytime in
master branch.

Enable checks.

* Go to [Settings] -> [Integrations & services ]
* Click [Add service] in [Services]
* Enable [Travis CI]

Protect the `master` branch.

* Go to [Settings] -> [Branches]
* Click [Choose a branch...] under [Protected branches] and select [master]
* Tick [Protect this branch], [Include administrators], [Require status checks
  to pass before merging], [Require branches to be up to date before merging],
  [Travis CI], and [Jenkins] in [Status checks found in the last week for this
  repository]. Remember that the checks must be executed at least once before
  showing up (you might need to push a branch to the repository to trigger
  tests).
* Click [Save changes]

## Managing branches

### Fix branch

Branch name for issues and bugs should start with `issue-$NUMBER`, where
$NUMBER is issue number. If the branch fixes multiple issues, use reasonably
meaningful branch name.

### Release branch

Branches for upcoming release should be named with a prefix `release_` and
release version number.

### Feature branch

TBW

## Creating a PR

See [Creating_Pull_Request](../Creating_Pull_Request).

## Reviewing a PR

TBW

## Merging a branch

When merging a branch, make sure that:

* the PR is reviewed and approved by the reviewer
* the PR passes the tests
* prefix the PR with `[Backward Incompatible]` so that the squash-and-merge
  commit will show the commit has backward incompatibilities

### Additional advice for reviewer

* Does the PR has tests? Unless it is related to tests themselves, the PR
  should have tests for the change
* Does the PR have update to `README`? If the change is made to any variables
  under `defaults` and `vars`, corresponding change should be made to `README`
  as well
* Is `meta/main.yml` is correct? When the list of supported platform changes,
  `meta/main.yml` should be updated
* if the PR introduce backward incompatible change, prefix the PR title with
  `[Backward Incompatible]` so that the next release will not miss
  incompatibilities in the release

When you merge a branch, the merge should be "squash and merge", so that
changes from one point can be summarized in one line logs. This is especially
useful when you draft release note.


