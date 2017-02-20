Table of Contents
=================

  * [Fixing an issue](#fixing-an-issue)
    * [Triaging an issue](#triaging-an-issue)
    * [Assign the issue to yourself](#assign-the-issue-to-yourself)
    * [Preparing the branch](#preparing-the-branch)
    * [Fixing an issue](#fixing-an-issue-1)

# Fixing an issue

## Triaging an issue

See [Triaging_Issue](Triaging_Issue).

## Assign the issue to yourself

When you are going to fix an issue, open the issue and assign yourself if
nobody is assigned. If someone has been assigned to the issue, discuss with the
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

Create a branch for the issue. The branch name should be "issue-$NUMBER". If
the branch will include mutiple fixes for issues, create a discriptive branch
name.

```
git checkout -b issue-$NUMBER
```

## Fixing an issue

Fix the issue in your local repository. Make sure unit tests and integration
tests, if any, pass on your local machine.

When all tests pass, push the branch.

```
git push --set-upstream origin issue-$NUMBER
```
