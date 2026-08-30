# ISyE 524 student repository: project status

Last updated: 2026-08-30

This file is the restart handoff for making this repository a simple, complete
Julia and JuMP environment that students can clone and use. Update it whenever
a reviewed checkpoint materially changes the state below.

## Baseline at this handoff

- Branch: `main`
- Committed and pushed baseline:
  `0575586650753e98db85190a8fc1bb2b752c7609`
  (`Added TopBrass-Intro notebook`)
- GitHub `origin/main` was checked directly and points to that commit.
- GitHub Actions run 33311643570 passed for that commit.
- GitHub reports that `main` is not protected, and the repository has no
  releases yet.
- The maintainer pre-commit hook is enabled with
  `core.hooksPath=.githooks`.
- `.quarto/`, `student-work/`, and `submissions/` exist locally as needed and
  are intentionally ignored.

The pushed baseline contains the tooling foundation, Homework 0, and the first
Top Brass class example. The current worktree contains the final validation and
release-polish changes described below; they have not yet been committed.

## Completed checkpoints

1. **Pinned Julia environment**
   - Julia 1.12 compatibility is enforced.
   - `Project.toml` and `Manifest.toml` pin JuMP, HiGHS, Ipopt, data packages,
     plotting, and repository tooling.
   - `scripts/setup.jl` instantiates and precompiles the environment and creates
     ignored student-work and submission directories.

2. **Student-facing VS Code workflow**
   - Recommended Julia, Jupyter, and Quarto extensions are declared.
   - Tasks cover setup, environment checks, repository updates, assignment
     copies, PDF tooling, PDF export, and maintainer notebook hygiene.
   - The update task performs a fast-forward-only pull and never resets or
     automatically stashes student changes.

3. **Installation verification**
   - `notebooks/00-check-installation.ipynb` checks Julia, JuMP and HiGHS, a
     small LP, DataFrames, Plots, and Markdown mathematics.
   - `test/smoke.jl` checks the pinned environment, solver result, tables, and
     plots.

4. **Assignment and submission workflow**
   - Instructor templates under `assignments/<id>/` copy safely to ignored
     `student-work/<id>/` without overwriting existing work.
   - Quarto PDF export uses saved notebook content without re-running code and
     supports Quarto-managed TinyTeX or an existing system TeX.
   - Documentation covers embedded and external images, backups, PDF review,
     Windows, macOS, Linux, and WSL.

5. **Notebook hygiene and CI**
   - The cleaner removes code output and execution state while preserving
     Markdown attachments and notebook content.
   - The pre-commit hook cleans fully staged notebooks and refuses unsafe
     partially staged notebooks.
   - The main GitHub Actions job runs environment setup, notebook hygiene,
     example execution, assignment execution, and smoke tests on Julia 1.12.

6. **Homework 0 content**
   - `assignments/hw0/julia-tutorial.ipynb` is the interactive Julia tutorial.
   - `assignments/hw0/hw0.ipynb` is the Gradescope submission notebook.
   - Both use the Julia 1.12 kernel, contain no saved outputs, avoid
     environment-changing package commands, and run from top to bottom.
   - `assignments/hw0/README.md` documents the exact student workflow.
   - `test/assignment_notebooks.jl` executes both starter notebooks and checks
     the complete real-template copy.

7. **Top Brass class example**
   - `notebooks/01-TopBrass-Intro.ipynb` formulates, solves, and interprets the
     production-planning LP.
   - The legacy Clp and SCS material was removed; the example uses HiGHS only.
   - It checks `MOI.OPTIMAL` before reading values and obtains 650 football
     trophies, 1,100 soccer trophies, and profit 17,700.
   - `test/example_notebooks.jl` executes the example and rejects SCS or Clp.

8. **Fresh-clone student-path validation**
   - A temporary clone of committed baseline `0575586` started clean with no
     student-work or submission directories.
   - Setup and precompilation completed with Julia 1.12.7.
   - The installation notebook's code cells ran successfully with the expected
     LP solution and active fresh-clone project.
   - Starting `hw0` copied both assignment notebooks, refused tracked student
     work, and left Git clean because the working copy is ignored.
   - All committed local CI equivalents passed before the PDF correction.

9. **PDF and platform validation in the current worktree**
   - Quarto 1.10.18 installed TinyTeX 2026.08 for this user account and passed
     `scripts/check_pdf_tools.jl`.
   - End-to-end HW0 export produced a readable 10-page, US-letter PDF.
   - The export wrapper was corrected to avoid conflicting Quarto output paths.
   - The wrapper selects TinyTeX's portable TeX Gyre Cursor code font so Julia
     Unicode such as `π` and `²` appears in the PDF.
   - `test/platform_scripts.jl` covers the assignment-copy and PDF-command
     helpers. A lightweight GitHub Actions matrix now runs it on Ubuntu, macOS,
     and Windows; this matrix will run after the changes are pushed.

## Current uncommitted checkpoint

The expected worktree changes are:

- `README.md`: instructor wording that the repository evolves through the
  semester, formatted for readability;
- `scripts/export_pdf.jl`: corrected output path, portable Unicode code font,
  and testable command construction;
- `test/platform_scripts.jl`: cross-platform helper regression tests;
- `test/smoke.jl`: environment-only smoke coverage after moving helper tests;
- `.github/workflows/ci.yml`: lightweight Ubuntu/macOS/Windows helper matrix;
- `docs/maintainers.md`: documents the platform matrix;
- `PROJECT_STATUS.md`: this untracked restart handoff.

No commit or push should be performed until the instructor reviews this set.

## Verification performed

The committed baseline passed the complete local sequence on Julia 1.12.7:

```text
julia --startup-file=no --project=. scripts/notebook_hygiene.jl --check
julia --startup-file=no --project=. test/notebook_hygiene.jl
julia --startup-file=no --project=. test/example_notebooks.jl
julia --startup-file=no --project=. test/assignment_notebooks.jl
julia --startup-file=no --project=. test/smoke.jl
```

The complete sequence was rerun after the current worktree changes. Results
were 13 notebook-hygiene passes, 10 Top Brass passes, 16 Homework 0 passes, 10
environment passes, and 9 platform-script passes. The corrected PDF export and
its Unicode output were also checked directly.

The machine's older system TeX installation previously failed while loading
Latin Modern Lua font metrics. The supported TinyTeX path is now fully
validated; system TeX remains an optional path maintained by students who
already manage their own TeX installation.

## Remaining work, in recommended order

### 1. Review, commit, and push this validation checkpoint

Review the expected files above, run the full local test sequence, then commit
and push. Confirm that the full Linux job and all three lightweight platform
jobs pass on GitHub.

### 2. Protect `main`

In GitHub repository settings, add a branch ruleset or classic branch
protection for `main`. Require pull requests if desired and require the
`Julia 1.12 environment and clean notebooks` status check. Consider whether the
three lightweight platform checks should also be required. This needs an
authenticated repository administrator; the public API inspection used for
this handoff cannot change the setting.

### 3. Make rollout decisions

Before directing students to the repository, decide whether to add a license,
support/contact instructions, and a named release tag. These are instructor
policy decisions and were not invented here. There is currently no GitHub
release.

### 4. Optional native-platform spot checks

The CI matrix checks path-safe Julia helpers on Linux, macOS, and Windows. It
does not exercise the VS Code user interface, a native Windows/WSL Quarto
installation, or every system TeX distribution. If practical, follow the
student guide once on the platforms students will actually use and record any
platform-specific correction.

### 5. Add later course material only when supplied

Do not invent more examples, assignments, or data. When the instructor supplies
the next source files, place read-only examples in `notebooks/` and copied
assignment templates in `assignments/<id>/`, then add focused execution tests.

## Resume point

Start with:

```text
git status --short --branch
git diff --check
julia --startup-file=no test/platform_scripts.jl
```

Then review the worktree changes and run the complete local CI sequence before
committing. The next content checkpoint waits for instructor-supplied material.
