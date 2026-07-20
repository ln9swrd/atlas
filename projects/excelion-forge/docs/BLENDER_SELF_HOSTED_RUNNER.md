Blender integration: self-hosted runner setup
=============================================

Purpose
-------
Provide instructions to set up a self-hosted GitHub Actions runner that can execute Blender headless integration tests. Useful because Blender is a large native dependency and not available on GitHub-hosted runners.

Prerequisites
-------------
- A machine (Linux recommended) with sufficient disk and GPU/CPU resources.
- Administrative access to install software and run services.
- Blender installed and accessible from PATH.

Steps
-----
1. Create a directory for the runner and download GitHub's runner binary for your OS. Follow GitHub docs: https://docs.github.com/en/actions/hosting-your-own-runners

2. Register the runner for the repository or organization. Configure it as a service so it runs continuously.

3. Install Blender on the runner host. On Ubuntu, example:

```bash
sudo snap install blender --classic
# or download tarball from blender.org and unpack
```

4. Confirm Blender can be run headless:

```bash
blender --background --version
```

5. Add any system dependencies your tests need (fonts, libs, etc.).

6. On the runner, install Python and project dependencies. Use the same Python version as CI (see `.github/workflows/ci.yml`). Example:

```bash
sudo apt install python3.11 python3.11-venv
python3.11 -m venv venv
. venv/bin/activate
pip install -e .[dev]
```

7. Run Blender integration tests through the helper script added in `tests/integration/run_in_blender.py`:

```bash
blender --background --python tests/integration/run_in_blender.py -- tests/integration/test_blender_validation.py
```

CI job example
--------------
Create a job in your GitHub Actions workflow that targets the self-hosted runner label, e.g.:

```yaml
jobs:
  integration:
    runs-on: [self-hosted, linux, blender]
    steps:
      - uses: actions/checkout@v4
      - name: Run Blender tests
        run: |
          blender --background --python tests/integration/run_in_blender.py -- tests/integration/test_blender_validation.py
```

Notes
-----
- Keep the runner secure and only register trusted machines. Runners have access to repository secrets when used in workflows.
- Test artifacts (logs, exported files) can be uploaded from the runner back to GitHub Actions using `actions/upload-artifact` in the workflow step.
