# Exporting a notebook to PDF

Assignments are submitted to Gradescope as PDF files. The repository uses
Quarto to convert a saved Jupyter notebook, including its Markdown mathematics
and saved cell results, into a PDF.

## 1. Install Quarto

Install the current release of [Quarto](https://quarto.org/docs/download/) for
your operating system. The Quarto VS Code extension does not replace the Quarto
command-line program. Restart VS Code after installation so its terminal and
tasks can find the `quarto` command.

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
packages through your existing TeX distribution's normal package manager.

## 3. Export the assignment

Work from the personal notebook created under `student-work/`, not the tracked
template under `assignments/`. For example, the `hw01` notebook should be
`student-work/hw01/hw01.ipynb`; exporting it creates `submissions/hw01.pdf`.

Handwritten models can be inserted as Markdown-cell attachments or referenced
from an `images/` directory beside the notebook. See
[Working on assignments](assignments.md#images-and-handwritten-work) for the
image workflow. Neither method requires another Julia package or export tool.

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

Open the generated PDF and check every page before uploading it to Gradescope.
In particular, verify that equations, tables, plots, long lines, and page breaks
are readable and that no requested output is missing.

## Terminal equivalents

For Quarto-managed TinyTeX:

```text
julia --startup-file=no --project=. scripts/export_pdf.jl student-work/hw01/hw01.ipynb
```

For an existing system TeX installation:

```text
julia --startup-file=no --project=. scripts/export_pdf.jl --system-tex student-work/hw01/hw01.ipynb
```

## Troubleshooting

- If VS Code reports that `quarto` was not found, install Quarto and restart VS
  Code completely.
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
