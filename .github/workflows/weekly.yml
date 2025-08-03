name: Weekly Jobs

on:
  schedule:
    - cron: '0 0 * * 0'  # This runs at midnight every Sunday

jobs:
  shellcheck:
    runs-on: ubuntu-latest
    steps:
      - name: Install dependencies
        run: |
          sudo apt-get -y install shellcheck
      - name: Analysing the code with Shellcheck
        run: |
          shellcheck -e SC1091 --severity=error $(git ls-files '*.sh')

  pylint:
    runs-on: ubuntu-latest
    steps:
        - name: Install dependencies
          run: |
            python -m pip install --upgrade pip
            pip install pylint
        - name: Analysing errors the code with pylint
          run: |
            pylint $(git ls-files -m '*.py')
