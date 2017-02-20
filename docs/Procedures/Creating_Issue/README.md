Table of Contents
=================

  * [Creating an issue](#creating-an-issue)
    * [Creating an issue in the repository that describe the bug if not already created](#creating-an-issue-in-the-repository-that-describe-the-bug-if-not-already-created)
    * [Adding labels to the issue](#adding-labels-to-the-issue)
    * [Adding a milestone to the issue (optional)](#adding-a-milestone-to-the-issue-optional)
    * [Assigning the issue to a sysadmin (optional)](#assigning-the-issue-to-a-sysadmin-optional)
    * [Closing an issue](#closing-an-issue)

# Creating an issue

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

## Closing an issue

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
