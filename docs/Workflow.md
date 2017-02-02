Table of Contents
=================

  * [Table of Contents](#table-of-contents)
  * [Fixing a bug or an issue in a role](#fixing-a-bug-or-an-issue-in-a-role)
    * [Creating an issue in the repository that describe the bug if not already created](#creating-an-issue-in-the-repository-that-describe-the-bug-if-not-already-created)
    * [Adding labels to the issue](#adding-labels-to-the-issue)
    * [Adding a milestone to the issue (optional)](#adding-a-milestone-to-the-issue-optional)
    * [Assigning the issue to a sysadmin (optional)](#assigning-the-issue-to-a-sysadmin-optional)
  * [Triaging an issue](#triaging-an-issue)
  * [Fixing an issue](#fixing-an-issue)
    * [Preparing the branch](#preparing-the-branch)
    * [Fixing the issue](#fixing-the-issue)
    * [Creating a pull request](#creating-a-pull-request)
  * [Closing an issue](#closing-an-issue)
  * [Enhancing a role or adding new feature (WIP)](#enhancing-a-role-or-adding-new-feature-wip)
  * [List of labels](#list-of-labels)
  * [Weekly review](#weekly-review)
  * [Bug Squashing day](#bug-squashing-day)

# Fixing a bug or an issue in a role

## Creating an issue in the repository that describe the bug if not already created

The title should describe the issue, not the expected result, for example, "the
role does not support X", not "Support X". It should be what it should be, not
what should be done. A bad example is, "Support platform X" and a good example
is, "The role does not support platform X".

The comment body should describe:

* the issue in detail
* the expected result
* a possible action to be taken
* the version of role, ansible, and OS, when relevant
* include the way to reproduce the issue, if any

## Adding labels to the issue

Choose lables and add them to the issue. See the list of labels below and when
to assign which.

## Adding a milestone to the issue (optional)

If there is a planned milestone, such as the next release, consider assigning the issue to it.


## Assigning the issue to a sysadmin (optional)

If you are going to fix the issue yourself, assign your account. If you do not
know how to fix it or are unable to fix it, leave it empty

# Triaging an issue

When an issue is created, decide what to do with it. If the issue cannot be
fixed soon, add `pending` label to the issue and leave a comment on why. If the
issue can be fixed, assign the issue to a sysadmin.

Unassigned issues are reviewed and discussed on weekly basis. See [Weekly
review](#weekly-review).

# Fixing an issue

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

## Fixing the issue

Fix the issue in your local repository. Make sure unit tests and integration
tests, if any, pass on your local machine.

When all tests pass, push the branch.

```
git push --set-upstream origin issue-$NUMBER
```

## Creating a pull request

After your branch is pushed to `origin`, create a pull request. The title
should be either,

* the issue number
* the problem you have solved

The pull request comment should incude `fixes #issue-$NUMBER` when the pull
request solves issues to automatically close the issue.

Make sure all the tests pass in github. Broken branch or untested branch must
not be merged.

Close the pull request when all tests pass.

# Closing an issue

An issue can be closed when:

* The issue is resolved by a fix
* The issue has a lebel, `needs_feedback` and no feedback has been provided by
  the reporter within a month
* The issue is labled as `invalid`
* The issue has not been resolved within extensive period longer than six
  months

An issue will be closed if a pull request refers to the issue.

Close issues when:

* one of the above conditions is met
* reviewing the issue at regular interval

# Enhancing a role or adding new feature (WIP)

When enhancing a role, such as supporting other platforms, create an issue and
label it with `enhancement`. To create an issue, see [Creating an issue in the
repository that describe the bug if not already
created](#creating-an-issue-in-the-repository-that-describe-the-bug-if-not-already-created).

# List of labels

| Name | Description | Examples |
|------|-------------|----------|
| bug               | Bugs, regressions, and something the role should do but does not | Undocumented variables, broke build |
| duplicate         | The issue is a duplicate of other issues | N/A |
| enhancement       | The issue enhances the role, such as adding supported platforms, implementing new feature | Supporting new platform, adding new functionality |
| invalid           | The issue cannot be reproduced, it cannot be fixed, or it is not an issue of the role | Issues caused by mis-configuration |
| risk treatment    | The issue is implied by risk treatment results, which must be implemented | Issues mentioned in risk treatment plan |
| pending           | The issue cannot be resolved but will be | The issue is blocked by some other issues |
| needs\_feedback   | Waiting for feedback from the reporter | More information is needed to resolve the issue |

# Weekly review

The purpose of Weeekly review is, updating the ticket status on a weekly basis
and making sure that someone is assigned to as many issues as possible.

| Action | Description |
|--------|-------------|
| Triaging issues                       | Triaging issues by labeling them |
| Assigning issues to a participant     | Assign unassigned issues |
| Closing bugs                          | Close issues that meet the closing criteria |

Weekly review is held on Monday or the first work day of the week.

# Bug Squashing day

Every month, a Bug Squashing day is held. The day is when all sysadmins review
remaining issues and squash bugs. The purpose of Bug Squashing day is, tidying
up issues, focusing on issues without being bothered by other regular tasks.

The issues focused on that day, chosen by the participants, may not necessarily
be resolved on that day. The point is focusing on issues, resolving as many
issues as possible, and moving projects forward.

The table below describes actions to be taken in a Bug Squashing day.

| Action | Description |
|--------|-------------|
| Reviewing issues              | List all issues unassigned to anyone, assign the issues to someone, or label it with `pending` |
| Reporting progress            | Participants will report the progress of their assigned issues |
| Fixing bugs                   | The participants decide one or more of issues to resolve by the end of that day and work on it |

The participants are expected to update the tickets, leaving comments about
progress, before the day so that everyone would shared the progress overview,
and the "reporting progress" would be short.

Next Bug Squashing day will be announced in the closing.
