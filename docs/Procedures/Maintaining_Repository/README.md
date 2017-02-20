Table of Contents
=================

    * [ACL](#acl)
    * [Branches](#branches)
      * [Fix branch](#fix-branch)
      * [Release branch](#release-branch)
      * [Feature branch](#feature-branch)
      * [Requesting a PR](#requesting-a-pr)
    * [Reviewing a PR](#reviewing-a-pr)
    * [Merging a branch](#merging-a-branch)
      * [Additional advice for reviewer](#additional-advice-for-reviewer)
    * [Protecting master branch](#protecting-master-branch)

## ACL

When creating a repository, assign ACL

| Team | ACL |
|------|-----|
| Developer | Write |
| SysAdmins | Admin |

If you want others to see private repo, assign the following ACL

| Team | ACL |
|------|-----|
| Read and Pull | Read |

## Branches

### Fix branch

Branch name for issues and bugs should start with `issue-$NUMBER`, where
$NUMBER is issue number. If the branch fixes multiple issues, use reasonably
meaningful branch name.

### Release branch

Branches for upcoming release should be named with a prefix `release_` and
release version number.

### Feature branch

TBW

### Requesting a PR

When creating a PR, make sure that:

* the tests passes
* the description is provided
* if the PR fixes an issue, mention the issue number in the description or in
  the commit log
* `README` is up-to-date when new variable is introduced, default value is
  changed, or a variable is removed, the change should be documented.
* When the PR removes comments, approval from the author of the comment is
  obtained
* When the PR disables tests, `pending` is added to the failed test with an
  argument as the reason, and the issue that describes the reason is created
* the branch can be merged without changes

After creating a PR, request a review from the Project Members. You may assign
multiple reviewer. If the PR changes the Policy, the Procedures, or rules,
assign the reviewer to all Project Members. To ensure that the PR is reviewed,
it is recommended to notify the reviewer in hipchat of the request.

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

## Protecting master branch

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
  showing up.
* Click [Save changes]

