# Maintainer workflow

Only course maintainers should commit changes to tracked course files. Before
working on notebooks, complete the [installation instructions](installation.md)
and run the standard repository setup task so the Julia environment is
available.

Before publishing an assignment, also follow the
[assignment-template guidance](../assignments/README.md). Each assignment
README should direct students to the central
[Assignments and PDF Submission](canvas-assignment-workflow.md) workflow.

## Add course packages or solvers

The direct package list is in `Project.toml`; `Manifest.toml` records the
resolved versions and their dependencies. `scripts/setup.jl` activates this
project and calls `Pkg.instantiate()` and `Pkg.precompile()`. There is no
separate package list to edit in the setup script.

For additions that every student should receive:

1. From the repository root, start the supported Julia version:

   ```text
   julia --startup-file=no --project=.
   ```

2. At the `julia>` prompt, use the package manager with the actual package
   names selected for the course. The names below are placeholders:

   ```julia
   import Pkg
   Pkg.add(["PackageName", "SolverPackageName"]; preserve=Pkg.PRESERVE_ALL)
   Pkg.precompile()
   Pkg.status()
   ```

   `PRESERVE_ALL` keeps existing dependency versions while resolving the new
   additions. If that cannot resolve, investigate the compatibility conflict
   and deliberately select which existing packages to update. Review the
   resulting diff in both TOML files. Do not edit the manifest manually.
   See the [Pkg API reference](https://pkgdocs.julialang.org/v1/api/).
3. Extend `test/smoke.jl` with a small use of each new package. For a solver,
   solve a representative model and check termination status and the expected
   solution within suitable tolerances. The existing check solves an LP with
   HiGHS but only imports Ipopt; it does not yet verify an Ipopt solve.
4. Add an example or update the installation notebook so students can verify
   the new functionality. Installing a solver does not change existing
   notebooks' choice of optimizer. Use the solver's documented constructor
   and a model class it supports; the
   [JuMP solver guide](https://jump.dev/JuMP.jl/stable/installation/#Supported-solvers)
   lists capabilities and extra installation requirements.
5. Update the README's included-package list and any assignment instructions.
   Run setup, the environment check, and the notebook checks described below
   before publishing. Verify new solver installations on the student operating
   systems. Currently the full environment runs in CI only on Ubuntu; the
   Windows/macOS jobs test workflow helpers without installing the course
   packages. Extend CI if automated solver coverage on those platforms is needed.
6. Commit and publish `Project.toml` and `Manifest.toml` together with the tests,
   examples, and documentation. Announce the additions and direct students to
   [Updating course packages and solvers](package-updates.md), identifying any
   new example they must run and any evidence they should submit.

The existing **ISyE 524: Update course repository** task already performs a
fast-forward pull followed by setup. Students then run **ISyE 524: Run
environment check**. Adding ordinary dependencies needs no new VS Code task or
setup-script changes. Instantiation installs the state recorded in the
manifest; see [Pkg environments](https://pkgdocs.julialang.org/v1/environments/).

### Solvers with separate installation or licensing

Before making a solver required, document its supported platforms, binary
installation if needed, license setup, and a small solve that verifies access.
For example, the current [Gurobi.jl installation
instructions](https://jump.dev/JuMP.jl/stable/packages/Gurobi/) install solver
binaries through the package manager but still require a separately configured
license. For MOSEK, JuMP integration uses `MosekTools` and `Mosek`; notebooks
that import both should list both as direct dependencies. Follow the
[MosekTools instructions](https://jump.dev/JuMP.jl/stable/packages/MosekTools/)
for installation, licensing, and optimizer selection.

Keep license files and credentials outside the repository. Decide how licensed
tests will run before adding them to the default check: the current CI workflow
does not configure commercial solver licenses.

If only some students should install an additional solver, design a separate
optional environment and matching setup/check tasks. Any dependency added to
the root project is installed for everyone by standard setup. An optional
environment also needs explicit notebook activation instructions because the
current VS Code configuration selects the root course project. This optional
workflow is not currently implemented.

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

A separate lightweight job tests the assignment-copy, PDF-command, and course
reset helpers on Ubuntu, macOS, and Windows without installing the full Julia
package environment on every runner. Reset tests use temporary local Git
repositories and verify backup recovery, personal-file protection, and update
failures; they never reset the maintainer's checkout.

The workflow never cleans and commits files on GitHub. A failing notebook check
must be corrected locally and pushed again. In the repository-protection
checkpoint, its `Julia 1.12 environment and clean notebooks` job will become a
required status check before merging.

## Where VS Code tasks are implemented

[`.vscode/tasks.json`](../.vscode/tasks.json) defines the task labels, commands,
arguments, and input prompts shown by **Tasks: Run Task**. The commands call
Julia scripts under `scripts/`:

- [`pull.jl`](../scripts/pull.jl) performs the ordinary fast-forward-only update.
- [`reset_course.jl`](../scripts/reset_course.jl) implements the separate reset
  task. It verifies the course remote and protected paths, fetches the published
  version, creates the external backup, resets course files, restores personal
  settings, and launches setup. It uses only Julia standard libraries and Git.
- [`setup.jl`](../scripts/setup.jl) installs and precompiles the Julia environment.

Run `julia --startup-file=no test/reset_course.jl` to exercise reset and recovery
without touching your checkout. Student-facing instructions are in
[Help with course updates](course-updates.md).
