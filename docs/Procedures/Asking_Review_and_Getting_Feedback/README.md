Table of Contents
=================

  * [Asking Review and Getting Feedback](#asking-review-and-getting-feedback)
    * [Overview](#overview)
    * [Making sure all the tests pass](#making-sure-all-the-tests-pass)
    * [Assigning Reviewer](#assigning-reviewer)
      * [Review timeout](#review-timeout)
    * [Fixing the branch](#fixing-the-branch)
    * [Merging the PR](#merging-the-pr)
    * [Deleting the branch](#deleting-the-branch)

# Asking Review and Getting Feedback

## Overview

![Asking Review and Getting Feedback](images/Asking_Review_and_Getting_Feedback.png)

## Making sure all the tests pass

PRs must pass all the tests. See the build status in the PR.

## Assigning Reviewer

When creating a PR, the author of the PR must request review, enforced by
settings in project and role repositories. Merging PRs is blocked until at
least one reviewer approves PR.

It is not mandatory but recommended to notify the reviewers in hipchat. Github
sends notifications to the reviewers but it is always a good idea to make sure
your PR is not forgotten.

When the PR needs to be merged urgently, such as fixing a show-stopper in
development or deployment, and the author cannot wait the review longer than
limits described below, the author must notify the assignee, either in hipchat
or the description, of the urgency and/or the deadline when assigning the PR to
the reviewer.

### Review timeout

The author of the PR may remove the initially assigned reviewer and assign the
PR to others when:

* the PR is not reviewed within 24 hours, excluding weekdays and public
  holidays, and no response is given from the reviewer
* the PR is not reviewed within 48 hours, excluding weekdays and public
  holidays
* the deadline the author has set is missed

## Fixing the branch

When the PR is reviewed and the PR is not approved, fix the branch with the
feedback or discuss with the reviewer. Repeat the process from [Making sure all
the tests pass].

Should the discussion stacks, ask the Project Owner in case of
`ansible-project`, or CTO in case of `ansible-role`.

## Merging the PR

When the PR is reviewed and approved, merge the PR into `master` branch.

Merge the branch by "Squash and merge". It _squashes_ multiple commits in the
PR into a single commit and merge the branch. This makes commit logs clean and
preserve each commit in the history.

## Deleting the branch

Delete the branch if the branch will no longer be used. Be aware that, when
releasing, the merged branch is still needed to tag the branch. Delete the
branch when releasing finishes. Merged branches should not be left in the
repository.
