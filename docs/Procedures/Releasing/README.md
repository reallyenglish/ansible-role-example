Table of Contents
=================

  * [Table of Contents](#table-of-contents)
  * [Versioning](#versioning)
  * [Releasing a role](#releasing-a-role)
    * [Before releasing](#before-releasing)
    * [Release procedure](#release-procedure)
    * [failures and bugs in galaxy](#failures-and-bugs-in-galaxy)
      * [Importing role can fail](#importing-role-can-fail)
      * [galaxy fails to extract role name from repository name](#galaxy-fails-to-extract-role-name-from-repository-name)

# Versioning

The version is three digits separated by dot.

| Index         | Description | When to bump |
|---------------|-------------|--------------|
| First digits  | Major version | The release is _NOT_ backward compatible |
| Second digits | Minor version | The release introduces new functionalities, and is backward compatible |
| Third digits  | Bug fix point release version | The release contains bug fixes only, and is backward compatible |

The version MAY have a suffix.

| suffix | Description |
|--------|-------------|
| `-beta$NUMBER` | The release is beta release, and not ready for public. $NUMBER is either null or the version of the beta release. $NUMBER must be digit.|

# Releasing a role

## Before releasing

When releasing a role, consider the followings:

* Does the role support all listed platforms? They should be supported.
* If you decide not to support a platform, create an issue and label it with
  `pending`. However, if it is obvious, like, the role is specifically targeted
   to a platform, such as a role that configures `yum` or an application that does
   not support other platform, you do not have to create an issue.
* Does `README.md` is correctly written? Be nice to possible users. Use
  professional phrase.

## Release procedure

For initial release, use `1.0.0`.

Suppose, you are going to release `1.0.0`

* Notify other members of the repository that you are going to release the
  role. As this is just a heads-up, simply mention names in PR comment.
* Create a pre-release branch
    * `git checkout master`
    * `git pull`
        * make sure that your default action for `pull` is rebase, see [Fixing an issue](../Fixing_Issue/README.md#fixing-an-issue-1)
    * `git checkout -b 'release_1.0.0'`
* Push the branch
    * `git push --set-upstream origin release_1.0.0`
* Do the last work on the branch if any
* Update `CHANGELOG.md` and commit
* Make sure Jenkins test passes in the branch
    * Open the github repository, [branches] -> [1.0.0]
* Create a PR for the release. See
  [Creating_Pull_Request](../Creating_Pull_Request).
    * When you merge the PR, do NOT delete the branch yet
* Create a release on github
    * [releases] -> [Create a new release]
    * [Tag version] -> `1.0.0`
    * [Target] -> `release_1.0.0`
    * [Release title] -> `1.0.0`
    * Describe the release in the release note
    * tick [This is a pre-release] if the release is not a public release
* Review the release
* Publish the release
    * Open the draft version of the release
    * Click [Publish release]
* Import the role from galaxy console (this procedure should not be here but see [the reason](#failures-and-bugs-in-galaxy)).
    * Visit https://galaxy.ansible.com/roleadd#/
    * Make sure the role is shown in the page. If not, you need to refresh
      repositories from github, which is almost always true when you have just
      created a new role. The icon to refresh roles is located at the top of
      the page
    * Click an icon to "Import Role"
    * Make sure the import log does not show any warnings or errors
    * Make sure the role name is correctly set (the role name must not have
      `ansible-role-` prefix in the name). The log contains role name. If not,
      go back to [Import Your Roles from GitHub] page and click an icon looks
      like a geer, where you can manually change the role name
* Remove the release branch from the github repository

## failures and bugs in galaxy

Galaxy has been known to be _at early stage of developement_. It is rare to see
failures when `ansible-galaxy` is invoked, but its web service has some rough
edges. This is the reason why you need to manually make sure the import job is
successful when releasing.

### Importing role can fail

It has been observed that galaxy's import jobs sometimes hang. It simply shows
the job is running but never finishes. Repeating import process does not help.
The only solution seems to be waiting for the job to bail out after some time.

galaxy implements basic sanity checks. As the source code is not open, how it
checks roles is unknown. From the past experiences, it appears that it checks:

* no funky characters in `meta/main.yml`
* supported platform name is one of known platforms

As import jobs rely on github, when github has issues, the job also fails.

### galaxy fails to extract role name from repository name

For whatever reason unknown to me, `meta/main.yml` does not have `name` field.
When galaxy imports a role, it extract role name from the name of the
repository. The logic is not open but, when the repository name contains some
prefix, the prefix is removed. One of the prefixes is (or used to be?)
`ansible-role-`. Say, if the repository name is `ansible-role-foo`, the role
name determined by galaxy is `USERNAME.foo`, where USERNAME is either
individual user name or organization name.

This worked and sometimes failed (I have created an issue once and the
maintainer said it was a bug). But recently imported roles have incorrect
names, like `USERNAME.ansible-role-foo`. I am not sure whether it was caused by
a bug or the maintainer changed the logic, but anyway, the end result is not
what you expect as other roles and projects assume correct name in
`requirements.yml` and `roles` variables.

TODO review the procedure with findings from past releases
TODO create a BPMN diagram of the procedure
