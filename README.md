# Close expired issues based on a label
This is an Action that closes expired issues based on the provided label, based on [bdougie/close-issues-based-on-label](https://github.com/bdougie/close-issues-based-on-label).

## Usage

To test this GitHub Action, replace the `LABEL` variable with one you want to check an close on a regular cadence.

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
    - name: weekly-expired-issue-closure
      uses: piroor/close-expired-issues-based-on-label@master
      env:
        LABEL: wontfix
        EXCEPTION_LABELS: in-progress, help wanted
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        EXPIRE_DAYS: 7
```
