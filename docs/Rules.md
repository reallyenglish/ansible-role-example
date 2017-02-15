Table of Contents
=================

  * [Table of Contents](#table-of-contents)
  * [Rules](#rules)
    * [Public or private repository](#public-or-private-repository)
    * [ACL](#acl)
    * [Branches](#branches)
      * [Fix branch](#fix-branch)
      * [Release branch](#release-branch)
      * [Feature branch](#feature-branch)
    * [Protecting master branch](#protecting-master-branch)
    * [Licence](#licence)
    * [Box images](#box-images)
    * [YAML notation](#yaml-notation)
    * [Scripts](#scripts)
    * [Validation](#validation)
    * [Variable Naming Convention](#variable-naming-convention)
      * [Use dash-separated words](#use-dash-separated-words)
      * [Use $ROLE_ prefix](#use-role_-prefix)
      * [Use __ prefix for platform-specific defaults](#use-__-prefix-for-platform-specific-defaults)
      * [Use register_ prefix for registered variables](#use-register_-prefix-for-registered-variables)
    * [Documentation](#documentation)
      * [README.md](#readmemd)
      * [CHANGELOG.md](#changelogmd)
    * [QA](#qa)

# Rules

Here is a list of rules. Some rules are enforced by `ansible-role-qa`.

## Public or private repository

Make the repository private when:

* the role contains secret information, such as password, employee's name

Make the repository public when:

* the role does not contain secret information

Usually, your role should be reusable, meaning it should not contain project
specific information. Make your role generic.

The reason behind encouraging public repository is that:

* It forces you to act on disciplines
* It encourages you to create generic roles

These would encourage to improve the quality of code.

## Considerations for private repositories

When a repository is private, that usually means the role contains secret
information. Secret information must be protected by `ansible-vault` and the
key must not be transferred to third-parties, employees that do not have access
right to the secret information, in line with the information security policy.

Similarly, ACL to the repository must not include third-parties and other
employees that do not have access right to the secret information, in line with
the information security policy.

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

## Licence

Prefer BSD or ISC license. `qansible init` creates [ISC-based
license](http://cvsweb.openbsd.org/cgi-bin/cvsweb/src/share/misc/license.template?rev=HEAD)
by default.

## Box images

Virtual box images must be owned by the member of `ansible-role-*`
repositories, i.e. the employee or the contractors.

The box images must be created using [a branch in
packer-templates](https://github.com/reallyenglish/packer-templates/tree/reallyenglish-master).

## YAML notation

Use regular YAML notation such as:

```yaml
---

- name: foo
  template:
    src: template.j2
    dest: /path/to/file
```

Instead of:

```yaml
---

- name: foo
  action: template src=template.j2 dest=/path/to/file
```

## Scripts

Scripts installed by a role should be written in:

* `sh(1)`
* `python`
* the language that is supposed to be in the host, i.e. when the role installs a ruby application, `ruby`

Scripts installed by a role must not be written in:

* `bash(1)`

`bash(1)` is the source of incompatibilities.

## Validation

Templates and files should be validated where possible.

## Variable Naming Convention

When using variables, follow the rules below.

### Use dash-separated words

Use `foo_bar` for variables.

### Use `$ROLE_` prefix

All configurable variables in a role should start with the role name followed
by `_` when the exceptions below do not apply.

### Use `__` prefix for platform-specific defaults

All platform-specific default variables must start with `__`. These variables
must be used only in `defaults/main.yml` and `vars/*.yml`.

### Use `register_` prefix for registered variables

All registered variables in a role must start with `register_`.

## Documentation

### README.md

All default variables and platform-specific variables must be documented in
`README.md`.

Example playbook must be documented in `README.md`.

### CHANGELOG.md

When releasing a role, `CHANGELOG.md` must describe changes since the last release.

When the release includes incompatible changes, i.e. major version bump,
`CHANGELOG.md` must describe the incompatibilities and must explain what users
should do when upgrading.

Changes since release 1.0.0 can be summarised using the following command.

```sh
git log --no-merges --oneline  1.0.0..HEAD | sed -e 's/^/* /'
```

## QA

To assure the quality of roles, roles must be validated by `ansible-role-qa`.
All critical errors must be fixed. Warnings should be corrected as many as
possible.

Roles must have a `Jenkinsfile` and `.travis.yml`, must be tested before
merging, and must pass the tests.

Roles should have at least one integration test, especially when the role
configures a server application.

The test should test idempotency of the role.
