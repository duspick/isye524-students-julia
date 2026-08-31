# Maintainer workflow

Only course maintainers should commit changes to tracked course files. Before
working on notebooks, complete the [installation instructions](installation.md)
and run the standard repository setup task so the Julia environment is
available.

Before publishing an assignment, also follow the
[assignment-template guidance](../assignments/README.md). Each assignment
README should direct students to the central
[Assignments and PDF Submission](canvas-assignment-workflow.md) workflow.

## Enable the pre-commit safeguard

Git does not enable repository-provided hooks automatically. In each maintainer
clone, open **Tasks: Run Task** in VS Code and run this task once:

```text
ISyE 524 Maintainer: Enable pre-commit hook
```

The equivalent terminal command is:

```text
julia --startup-file=no scripts/install_hooks.jl
```

This sets the clone-local Git option `core.hooksPath` to `.githooks`. It does
not modify the user's global Git configuration.

Before each commit, the hook examines staged `.ipynb` files. It clears code-cell
outputs, execution counts, execution timing metadata, and saved widget state,
then stages the cleaned notebooks. Markdown cells, Markdown image attachments,
cell source, kernel information, and other notebook content are preserved.

If a notebook is only partially staged, the hook refuses to modify or stage it.
Resolve or stage its remaining changes and commit again. This prevents the hook
from accidentally including unrelated working-tree edits.

## Manual notebook commands

To clean every tracked course or assignment-template notebook, run:

```text
ISyE 524 Maintainer: Clean notebook outputs
```

To check without changing files, run:

```text
ISyE 524 Maintainer: Check notebook hygiene
```

Terminal equivalents are:

```text
julia --startup-file=no --project=. scripts/notebook_hygiene.jl --clean
julia --startup-file=no --project=. scripts/notebook_hygiene.jl --check
```

The default scan intentionally excludes `student-work/`, so students retain the
saved results needed for PDF export. `JSON.jl` is a direct repository-tooling
dependency used by these commands; course notebooks should not depend on it
unless the course material independently requires JSON processing.

## GitHub Actions

The `Repository checks` workflow runs on every push and pull request. It:

1. installs Julia 1.12 and instantiates the pinned course environment;
2. rejects tracked notebooks containing saved outputs or execution state;
3. tests that cleaning preserves Markdown image attachments; and
4. executes the code cells supplied in class example notebooks;
5. executes the code cells supplied in assignment starter notebooks; and
6. runs the Julia environment and assignment-copy smoke tests.

A separate lightweight job tests the assignment-copy and PDF-command helpers
on Ubuntu, macOS, and Windows without installing the full Julia package
environment on every runner.

The workflow never cleans and commits files on GitHub. A failing notebook check
must be corrected locally and pushed again. In the repository-protection
checkpoint, its `Julia 1.12 environment and clean notebooks` job will become a
required status check before merging.
