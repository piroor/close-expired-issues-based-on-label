# Close expired issues based on a label
This is an Action that closes expired issues based on the provided label, based on [bdougie/close-issues-based-on-label](https://github.com/bdougie/close-issues-based-on-label).

## Usage

To test this GitHub Action, replace the `LABEL` variable with one you want to check an close on a regular cadence.

This action takes four parameters via environment variables.

* `LABEL` (string): The name of a label for closable issues.
* `EXPIRE_DAYS` (integer, default = `0`): The number of days waiting to close issues after the last label is given.
* `EXTEND_DAYS_BY_REOPENED` (integer, default = same to `EXPIRE_DAYS`): The number of days waiting to close issues after last reopened by someone.
* `EXTEND_DAYS_BY_COMMENTED` (integer, default = same to `EXPIRE_DAYS`): The number of days waiting to close issues after last commented by someone.
* `EXCEPTION_LABELS` (commma separated strings): Names of labels which block closing of issues.
* `GITHUB_TOKEN (string): This must be `${{ secrets.GITHUB_TOKEN }}`.

For example:

```yml
on:
  schedule:
  - cron: 0 5 * * 3 
name: Weekly Expired Issue Closure
jobs:
  cycle-weekly-close:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: close wontfix issues
      uses: piroor/close-expired-issues-based-on-label@master
      env:
        LABEL: wontfix
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        EXPIRE_DAYS: 7
        EXTEND_DAYS_BY_REOPENED: 3
        EXTEND_DAYS_BY_COMMENTED: 3
        COMMENT: This issue has been closed due to no response within 7 days after labeled as "wontfix", 3 days after last reopened, or 3 days after last commented.
    - name: close partially-fixed issues
      uses: piroor/close-expired-issues-based-on-label@master
      env:
        LABEL: partially-fixed
        EXCEPTION_LABELS: in-progress, help wanted
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        EXPIRE_DAYS: 7
        EXTEND_DAYS_BY_REOPENED: 3
        EXTEND_DAYS_BY_COMMENTED: 3
        COMMENT: This issue has been closed due to no response within 7 days after labeled as "partially-fixed", 3 days after last reopened, or 3 days after last commented.
```
