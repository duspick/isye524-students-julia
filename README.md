# ISyE 524: Julia Student Environment

This repository provides the supported Julia environment for ISyE 524. It is
intended to give every student the same Julia, JuMP, solver, data, plotting,
notebook, and PDF-export workflow.

The repository is currently being assembled. The Julia environment is ready;
VS Code integration, setup checks, example notebooks, and Gradescope PDF export
will be added in subsequent reviewed checkpoints.

## Supported Julia version

Use Julia 1.12, installed with
[Juliaup](https://julialang.org/downloads/). The environment accepts Julia
1.12 patch releases and was initially generated with Julia 1.12.7.

After cloning this repository, open a terminal in the repository root and run:

```text
julia --project=. -e "using Pkg; Pkg.instantiate()"
```

`Project.toml` lists the course's direct dependencies. `Manifest.toml` records
the complete, tested dependency graph. Do not use `Pkg.add` from an individual
course notebook.

## Included Julia packages

The course environment includes:

- JuMP with the open-source HiGHS and Ipopt solvers
- CSV, DataFrames, NamedArrays, and XLSX for course data
- Plots for visualization
- Distributions and MathOptInterface for selected course material
- Printf from Julia's standard library for formatted output

Commercial solvers such as Gurobi and Mosek are intentionally not required by
the standard student environment.

## Planned student workflow

Students will work in Jupyter notebooks inside VS Code. Repository-provided VS
Code tasks will set up the Julia environment, check the installation, and
export completed notebooks to PDF for Gradescope.

PDF export will use Quarto. Students without an existing TeX installation will
be able to use Quarto-managed TinyTeX without adding it to the system `PATH`.
Students who already maintain TeX Live, MacTeX, or MiKTeX will be able to use
their existing installation instead.

## Repository layout

```text
data/        Data files used by notebooks
notebooks/   Course notebooks
scripts/     Setup and export helpers
test/        Environment and notebook smoke tests
```

Generated assignment PDFs and LaTeX intermediates will go in `submissions/`,
which is intentionally excluded from Git.

## For course maintainers

Changes to `Project.toml` must be made through Julia's package manager. Commit
the corresponding `Manifest.toml` change and verify the environment before
publishing it to students.
