# ISyE 524: Julia Student Environment

This repository provides the supported Julia environment for ISyE 524. It is
intended to give every student the same Julia, JuMP, solver, data, plotting,
notebook, and PDF-export workflow.

The repository is currently being assembled. The Julia environment, VS Code
integration, installation checks, and Gradescope PDF export are ready. Example
notebooks will be added in subsequent reviewed checkpoints.

## Supported Julia version

Use Julia 1.12, installed with
[Juliaup](https://julialang.org/downloads/). The environment accepts Julia
1.12 patch releases and was initially generated with Julia 1.12.7.

After cloning this repository, open the repository root in VS Code. When VS
Code offers to install the workspace's recommended extensions, accept the
recommendation. The repository recommends the Julia, Jupyter, and Quarto
extensions.

Open the Command Palette, select `Tasks: Run Task`, and run:

```text
ISyE 524: Set up / refresh Julia environment
```

The equivalent terminal command is:

```text
julia --startup-file=no --project=. scripts/setup.jl
```

In addition to installing the Julia packages, setup creates two local folders:

- `student-work/` for personal assignment copies
- `submissions/` for generated Gradescope PDFs

Both folders are excluded from Git. Course updates therefore do not overwrite
student answers, but students must keep a separate backup of `student-work/`.

`Project.toml` lists the course's direct dependencies. `Manifest.toml` records
the complete, tested dependency graph. Do not use `Pkg.add` from an individual
course notebook.

## Checking the installation

Open [notebooks/00-check-installation.ipynb](notebooks/00-check-installation.ipynb)
in VS Code. If prompted for a notebook kernel, select Julia 1.12, then choose
**Run All**. A successful run displays:

- the active Julia version and course project
- the optimal solution `(x, y) = (3.6, 2.8)` and objective value `22.0`
- a two-row results table
- a plot of the feasible region and optimal solution

The notebook also contains Markdown mathematics so students can confirm that
equations render in VS Code. Its outputs are intentionally cleared in Git; your
local outputs do not need to be committed.

For a quicker command-line check, run this VS Code task:

```text
ISyE 524: Run environment check
```

The equivalent terminal command is:

```text
julia --startup-file=no --project=. test/smoke.jl
```

## Included Julia packages

The course environment includes:

- JuMP with the open-source HiGHS and Ipopt solvers
- CSV, DataFrames, NamedArrays, and XLSX for course data
- Plots for visualization
- Distributions and MathOptInterface for selected course material
- Printf from Julia's standard library for formatted output

JSON is also included for the repository's notebook-cleaning tools; students do
not need to use it in course notebooks.

Commercial solvers such as Gurobi and Mosek are intentionally not required by
the standard student environment.

## Starting an assignment

Instructor templates are published in a separate folder for each assignment,
such as `assignments/hw01/`. Do not edit the tracked template directly. After
pulling the latest course files, run this VS Code task:

```text
ISyE 524: Start an assignment from its template
```

Enter the assignment name supplied by the instructor, such as `hw01`. The task
copies the complete template to `student-work/hw01/` and refuses to overwrite
an existing student copy. Work only in the new `student-work/` folder.

The equivalent terminal command is:

```text
julia --startup-file=no --project=. scripts/start_assignment.jl hw01
```

See [Working on assignments](docs/assignments.md) for the full workflow,
including handwritten images and backup guidance.

## Keeping course files current

As new course material is published, open `Tasks: Run Task` and run:

```text
ISyE 524: Update course repository
```

This task performs a fast-forward-only Git pull and then refreshes the Julia
environment. Work under `student-work/` is ignored by Git and is unaffected.
If a student edits a tracked course file and an update changes the same file,
Git stops instead of overwriting it. The task never resets or automatically
stashes student files.

## Exporting assignments to PDF

Assignments are exported from saved Jupyter notebooks with Quarto. Install
[Quarto](https://quarto.org/docs/download/), then use the repository's VS Code
tasks to check the PDF tools and export the active notebook. Generated PDFs are
placed in `submissions/` for review before uploading to Gradescope.

Students without TeX can explicitly install Quarto-managed TinyTeX without
adding it to the system `PATH`. Students who already maintain TeX Live, MacTeX,
or MiKTeX can select the separate system-TeX export task. The system-TeX task
disables Quarto's TinyTeX selection and automatic package installation.

See [Exporting a notebook to PDF](docs/pdf-export.md) for installation,
export, system-TeX, and troubleshooting instructions.

## Repository layout

```text
assignments/   Instructor-published assignment templates
data/          Shared data files used by notebooks
docs/          Student and maintainer instructions
notebooks/     Course notebooks and installation checks
scripts/       Setup, assignment, update, and export helpers
student-work/  Personal assignment copies; generated and ignored by Git
submissions/   Generated Gradescope PDFs; ignored by Git
test/          Environment and notebook smoke tests
```

## For course maintainers

Changes to `Project.toml` must be made through Julia's package manager. Commit
the corresponding `Manifest.toml` change and verify the environment before
publishing it to students.

See [Assignment templates](assignments/README.md) before publishing a new
starter notebook. See [Maintainer workflow](docs/maintainers.md) to enable the
notebook-cleaning hook and run the same checks enforced by GitHub Actions.
