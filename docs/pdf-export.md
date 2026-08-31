# Exporting a notebook to PDF

Assignments are submitted to Gradescope as PDF files. The repository uses
Quarto to convert a saved Jupyter notebook, including its Markdown mathematics
and saved cell results, into a PDF.

Use [Assignments and PDF Submission](canvas-assignment-workflow.md) for the
normal assignment sequence. This page provides the detailed PDF installation,
export, and troubleshooting reference.

Complete the [student installation guide](installation.md) first. It provides
the ordered Quarto and LaTeX installation choices; this page describes the
regular assignment-export workflow.

## 1. Install Quarto

Use the operating-system-specific commands in
[Step 8 of the installation guide](installation.md#8-install-quarto). The
Quarto VS Code extension does not replace the Quarto command-line program.
Restart VS Code after installation so its terminal and tasks can find the
`quarto` command.

In WSL, install the Linux build of Quarto and TinyTeX inside WSL and open the
repository in a **WSL** VS Code window. Installing either tool only on Windows
does not make it available to a WSL task.

A local or system LaTeX installation does not replace Quarto. Quarto converts
the saved notebook to LaTeX input and coordinates the render; LaTeX performs
the final typesetting into PDF.

Open the Command Palette, select **Tasks: Run Task**, and run:

```text
ISyE 524: Check PDF export tools
```

This reports the Quarto installation and which LaTeX distribution Quarto will
use.

## 2. Choose one LaTeX setup

### Recommended: Quarto-managed TinyTeX

Students who do not already maintain a TeX installation should run this VS Code
task once:

```text
ISyE 524: Install Quarto-managed TinyTeX (optional)
```

The task runs `quarto install tinytex` without `--update-path`. TinyTeX is
installed for your user account and is available to Quarto projects on that
account. It is not installed inside this Git repository, and it is not added to
the system `PATH`, so other programs continue to use any existing system TeX
installation. Installing or updating TinyTeX is always an explicit action; the
course setup and repository-update tasks never do either operation.

### Existing TeX Live, MacTeX, or MiKTeX installation

If you already maintain a TeX installation, you do not need TinyTeX. Use the
system-TeX export task described below. It passes `latex-tinytex: false` to
Quarto and disables Quarto's automatic LaTeX-package installation, so Quarto
does not select or modify its managed TinyTeX installation. Install any missing
packages through your existing TeX distribution's normal package manager. The
`lualatex --version` command must work in the VS Code integrated terminal; this
also supports a user-local TeX installation that is on `PATH`.

## 3. Export the assignment

Work from the personal notebook created under `student-work/`, not the tracked
template under `assignments/`. For Homework 0, the working notebook is
`student-work/hw00/hw00.ipynb`; exporting it creates `submissions/hw00.pdf`.

Handwritten models can be inserted as Markdown-cell attachments or referenced
from an `images/` directory beside the notebook. See
[Assignment files, images, and backups](assignments.md#images-and-handwritten-work)
for the image workflow. Neither method requires another Julia package or
export tool.

Before exporting:

1. Run all notebook cells in VS Code.
2. Confirm that there are no errors and that every requested result and plot is
   visible.
3. Save the notebook.
4. Keep the notebook active in the editor.

Then run exactly one of these tasks:

```text
ISyE 524: Export active notebook to PDF (TinyTeX)
ISyE 524: Export active notebook to PDF (system TeX)
```

The export uses the notebook's saved outputs and does not re-run its code. The
PDF is written to `submissions/` at the repository root. This directory is
excluded from Git.

Quarto reads the saved `.ipynb`, converts its Markdown and saved cell output
through its bundled document tools, and asks LaTeX to create the final PDF. In
WSL this entire pipeline runs as Linux processes; no Windows-side Quarto,
Julia, or LaTeX process is involved. Because the course export passes
`--no-execute`, Julia is not started during PDF export.

Open the generated PDF and check every page before uploading it to Gradescope.
In particular, verify that equations, tables, plots, long lines, and page breaks
are readable and that no requested output is missing.

## Terminal equivalents

For Quarto-managed TinyTeX:

```text
julia --startup-file=no --project=. scripts/export_pdf.jl student-work/hw00/hw00.ipynb
```

For an existing system TeX installation:

```text
julia --startup-file=no --project=. scripts/export_pdf.jl --system-tex student-work/hw00/hw00.ipynb
```

## Troubleshooting

- If VS Code reports that `quarto` was not found, install Quarto and restart VS
  Code completely. In WSL, confirm that `which quarto` reports a Linux path and
  that the lower-left corner of VS Code says **WSL**.
- Run `ISyE 524: Check PDF export tools` to see the Quarto and LaTeX paths in
  use.
- If the PDF omits results or plots, run all notebook cells and save the
  notebook before exporting again.
- If an external image is missing, check that its Markdown path is relative to
  the working notebook and that the image is inside the assignment folder.
- If an older TinyTeX can no longer install required packages, update it
  explicitly with `quarto update tinytex`, then retry the export.
- If the system-TeX task reports a missing LaTeX package, install it with your
  TeX distribution's package manager or use Quarto-managed TinyTeX instead.
