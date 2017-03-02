Table of Contents
=================

  * [Table of Contents](#table-of-contents)
  * [Versioning](#versioning)
  * [Releasing a role](#releasing-a-role)
    * [Before releasing](#before-releasing)
    * [Release procedure](#release-procedure)

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

* Notify other members of the repository that you are going to release the role
* Create a pre-release branch
    * `git checkout master`
    * `git pull
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
* Import the role from galaxy console
    * Make sure the import log does not show any warnings or errors
* Remove the release branch from the github repository

TODO review the procedure with findings from past releases
TODO create a BPMN diagram of the procedure
