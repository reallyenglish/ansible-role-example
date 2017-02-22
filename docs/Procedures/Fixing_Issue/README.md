Table of Contents
=================

  * [Table of Contents](#table-of-contents)
  * [Fixing an issue](#fixing-an-issue)
    * [Triaging an issue](#triaging-an-issue)
    * [Assign the issue to yourself](#assign-the-issue-to-yourself)
    * [Preparing the branch](#preparing-the-branch)
    * [Fixing an issue](#fixing-an-issue-1)
    * [Confirming the tests pass and the issue has been fixed](#confirming-the-tests-pass-and-the-issue-has-been-fixed)
    * [Ask for help](#ask-for-help)

# Fixing an issue

This document describes how to work on issues in repositories. This applies to
Project Members.

## Triaging an issue

If the issue has not been triaged, tag the issue with appropriate tags. See
[Triaging_Issue](../Triaging_Issue).

## Assign the issue to yourself

When you are going to fix an issue, open the issue and assign yourself if
nobody is assigned. If the issue has been assigned to someone, discuss with the
assignee.

## Preparing the branch

Merge the `master` branch into your local `master` branch. Before `git pull`
make sure that the default action of `pull` is `rebase`.

```
git config --global pull.rebase true
```

```
git checkout master
git pull
```
There should be no conflicts. If there is, that means something is wrong in
your local repository.

Create a branch for the issue. The branch name should be "issue-$NUMBER". If
the branch will include multiple fixes for issues, create a descriptive branch
name.

```
git checkout -b issue-$NUMBER
```

## Fixing an issue

Create one or more unit, and integration tests that should be successful when
you fix the issue.

Fix the issue in your local repository. Make sure unit tests, and integration
tests pass on your local machine.

## Confirming the tests pass and the issue has been fixed

When all tests pass, push the branch to see the build passes in Jenkins.

```
git push --set-upstream origin $branch_name
```

At this point, do NOT rush into creating a PR. You must confirm the test
result. To confirm,

* Open the repository URL
* Select your branch in `Branches`
* Click a green _check_ image in your branch

A pop-up shows up and it should say "All checks have passed".

Or, Jenkins would notify you, if you are a Project Member, of the result.

Fix the failure and repeat until the tests pass.

If the result is successful, proceed to create a PR. See
[Creating_Pull_Request](../Creating_Pull_Request) for the procedure.

## Ask for help

If you cannot fix it, ask the Project Members for help. You may remove yourself
from the assignee. Leave comments, what you cannot fix, or the failure.
