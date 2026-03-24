# Contributing

## Workflow

1. Branch from `develop`.
2. Keep changes scoped to one issue or release item when possible.
3. Open a pull request with a clear summary, testing notes, and linked issue or milestone.

## Local Setup

Install the package dependencies you need for the area you are changing. The ANN stage uses the optional R `keras` package and backend setup.

## Testing

Run the local test suite before opening a pull request:

```r
Rscript -e "testthat::test_dir('tests/testthat', reporter = 'summary')"
```

If you touch packaging or workflow files, also verify any relevant GitHub Actions configuration locally where practical.

## Documentation

- Update the README when user-facing behavior changes.
- Keep examples aligned with the current package behavior.
- Document limitations explicitly rather than implying support that does not exist yet.

## Pull Requests

- Keep pull requests focused and reviewable.
- Call out breaking changes clearly.
- Note any follow-up work or known limitations in the PR description.
