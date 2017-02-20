Table of Contents
=================

  * [Creating a pull request](#creating-a-pull-request)

# Creating a pull request

After your branch is pushed to `origin`, create a pull request. The title
should be either,

* the issue number
* the problem you have solved

The pull request comment should incude `fixes #issue-$NUMBER` when the pull
request solves issues to automatically close the issue.

Make sure all the tests pass in github. Broken branch or untested branch must
not be merged.

Close the pull request when all tests pass.
