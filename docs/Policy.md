Table of Contents
=================

  * [Table of Contents](#table-of-contents)
  * [Development policy for roles](#development-policy-for-roles)
    * [Public or private repository](#public-or-private-repository)
    * [Access control policy](#access-control-policy)
    * [Licence](#licence)
    * [Box images](#box-images)
    * [Scripts](#scripts)
    * [YAML notation](#yaml-notation)
    * [Validation](#validation)
    * [Variable Naming Convention](#variable-naming-convention)
      * [Use dash-separated words](#use-dash-separated-words)
      * [Use $ROLE_ prefix](#use-role_-prefix)
      * [Use double dashes as prefix for platform-specific defaults](#use-double-dashes-as-prefix-for-platform-specific-defaults)
      * [Use register_ prefix for registered variables](#use-register_-prefix-for-registered-variables)
    * [Documentation](#documentation)
      * [README.md](#readmemd)
      * [CHANGELOG.md](#changelogmd)
    * [QA](#qa)

# Development policy for roles

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

## Access control policy

In general, The Access Control Policy in the Secure Development Policy applies.

When a repository is private, that usually means the role contains secret
information. Secret information must be protected by `ansible-vault` and the
key must not be transferred to third-parties, employees that do not have access
right to the secret information, in line with the information security policy.

Similarly, ACL to the repository must not include third-parties and other
employees that do not have access right to the secret information, in line with
the information security policy.

## Licence

Prefer BSD or ISC license. `qansible init` creates [ISC-based
license](http://cvsweb.openbsd.org/cgi-bin/cvsweb/src/share/misc/license.template?rev=HEAD)
by default.

## Box images

Virtual box images must be owned by the member of `ansible-role-*`
repositories, i.e. the employee or the contractors.

The box images must be created using [a branch in
packer-templates](https://github.com/reallyenglish/packer-templates/tree/reallyenglish-master).

## Scripts

Scripts installed by a role should be written in:

* `sh(1)`
* `python`
* the language that is supposed to be in the host, i.e. when the role installs a ruby application, `ruby`

Scripts installed by a role must not be written in:

* `bash(1)`

`bash(1)` is the source of incompatibilities.

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

## Validation

Templates and files should be validated where possible.

## Variable Naming Convention

When using variables, follow the rules below.

### Use underscore-separated words

Use `foo_bar` for variables.

### Use `$ROLE_` prefix

All configurable variables in a role should start with the role name followed
by `_` when the exceptions below do not apply.

### Use double underscores as prefix for platform-specific defaults

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
