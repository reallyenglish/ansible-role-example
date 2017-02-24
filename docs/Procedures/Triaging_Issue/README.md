Table of Contents
=================

  * [Triaging an issue](#triaging-an-issue)
    * [List of labels](#list-of-labels)

# Triaging an issue

When an issue is created, decide what to do with it. If the issue cannot be
fixed soon, add `pending` label to the issue and leave a comment on why. If the
issue can be fixed, assign the issue to a sysadmin.

Unassigned issues are reviewed and discussed on weekly basis. See
[Weekly_Review](../Weekly_Review) for details.

## List of labels

| Name | Description | Examples | Color in hex |
|------|-------------|----------|--------------|
| bug               | Bugs, regressions, and something the role should do but does not | Undocumented variables, broke build | default |
| duplicate         | The issue is a duplicate of other issues | N/A | default |
| enhancement       | The issue enhances the role, such as adding supported platforms, implementing new feature | Supporting new platform, adding new functionality | default |
| invalid           | The issue cannot be reproduced, it cannot be fixed, or it is not an issue of the role | Issues caused by mis-configuration | default |
| risk treatment    | The issue is implied by risk treatment results, which must be implemented | Issues mentioned in risk treatment plan | `c7b2de` |
| pending           | The issue cannot be resolved but will be | The issue is blocked by some other issues | `7f878f` |
| needs\_feedback   | Waiting for feedback from the reporter | More information is needed to resolve the issue | `ffd1d1` |

The colors above were chosen from http://jfly.iam.u-tokyo.ac.jp/colorset/.
