# Contributing to calendar-cli

Contributions are mostly welcome (but do inform about it if you've used AI or
other tools). If the length of this text scares you, then I'd rather want you
to skip reading and just produce a pull-request in GitHub. If you find it too
difficult to write test code, etc, then you may skip it and hope the maintainer
will fix it.

## What to include

Every submission should ideally include:

- **Test code** covering the new behaviour or bug fix
- **Documentation** updates where relevant
- **A changelog entry** in `CHANGELOG.md` under `[Unreleased]`

## Development setup

```
make dev    # editable install with dev dependencies (pytest, ruff, pre-commit)
make test   # run the test suite
make lint   # run ruff
```

To enable the pre-commit hooks (linting on commit, tests/link-check on push,
conventional-commit message checks):

```
pre-commit install
pre-commit install --hook-type pre-push
pre-commit install --hook-type commit-msg
```

## Versioning and releases

The version is derived automatically from git tags via hatch-vcs — it is **not**
stored in the source. A release is made by tagging (`vX.Y.Z`) and pushing the
tag; a GitHub Actions workflow then builds and publishes to PyPI via trusted
publishing. There is nothing to bump by hand.

## Commit messages

Please follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
and write messages in the imperative mood:

- `fix: correct time-range search handling for recurring events`
- `feat: add new command`
- `docs: update README`

Rather than:

- `This commit fixes the time-range search`
- `Added new command`

Note: older commits in this repository predate this convention and do not
follow it.
