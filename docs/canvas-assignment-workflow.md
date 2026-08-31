# ISyE 524: Assignments and PDF Submission

Use this workflow for Homework 0 and later assignments. The
[public ISyE 524 GitHub repository](https://github.com/jlinderoth/isye524-students-julia)
is the authoritative source for current instructions and course files.

Complete the
[Start Here guide](https://github.com/jlinderoth/isye524-students-julia/blob/main/docs/canvas-start-here.md)
before beginning an assignment.

## 1. Update the course repository

Open the `isye524-students-julia` repository root in VS Code. Open the Command
Palette, select **Tasks: Run Task**, and run:

```text
ISyE 524: Update course repository
```

This downloads new course files and refreshes the Julia environment. It does
not overwrite work stored under `student-work/`.

Run this update before starting each newly announced assignment. Do not edit
tracked course files to resolve an update problem; preserve your work and read
the Git message before making changes.

## 2. Create your assignment copy

From **Tasks: Run Task**, run:

```text
ISyE 524: Start an assignment from its template
```

Enter the assignment name announced by the instructor. For the initial
assignment, enter:

```text
hw00
```

The task copies the complete template to `student-work/<assignment-name>/` and
refuses to overwrite an existing copy.

If the task reports that the assignment copy already exists, open that existing
folder and continue working there. Do not delete it and start over.

Do not edit files under `assignments/`. Those are instructor-published
templates. Do all of your work in the copy under `student-work/`.

## 3. Complete and check the notebook

Open the assignment notebook under `student-work/`. If prompted for a kernel,
choose Julia 1.12.

Before submitting:

1. Complete every requested Markdown and code cell.
2. Run all cells from top to bottom.
3. Confirm that there are no errors and that all requested tables, plots, and
   answers are visible.
4. Save the notebook.

For Homework 0, follow the
[Homework 0 instructions](https://github.com/jlinderoth/isye524-students-julia/blob/main/assignments/hw00/README.md).

If an assignment requires a handwritten model or other image, follow
[Assignment files, images, and backups: Images and handwritten work](https://github.com/jlinderoth/isye524-students-julia/blob/main/docs/assignments.md#images-and-handwritten-work).

## 4. Prepare PDF export once

PDF export requires the Quarto command-line program and a LaTeX installation.
The Quarto VS Code extension alone is not sufficient.

You normally perform this setup only once on each computer or WSL
distribution.

From **Tasks: Run Task**, run:

```text
ISyE 524: Check PDF export tools
```

If you do not already maintain TeX Live, MacTeX, or MiKTeX, use the recommended
course option and run this task once:

```text
ISyE 524: Install Quarto-managed TinyTeX (optional)
```

For operating-system-specific Quarto installation and the system-TeX option,
follow the authoritative
[PDF export guide](https://github.com/jlinderoth/isye524-students-julia/blob/main/docs/pdf-export.md).

## 5. Export and inspect the PDF

Run all notebook cells and save the notebook before exporting. Keep the
notebook active in the VS Code editor.

From **Tasks: Run Task**, run exactly one of these tasks:

```text
ISyE 524: Export active notebook to PDF (TinyTeX)
ISyE 524: Export active notebook to PDF (system TeX)
```

Use the TinyTeX task if you installed Quarto-managed TinyTeX. Use the system-TeX
task only if you maintain a separate TeX Live, MacTeX, or MiKTeX installation.

The task exports the notebook's saved content without rerunning its code. The
PDF is placed in `submissions/` at the repository root.

Open the PDF and inspect every page before uploading it to Gradescope. Check
that equations, tables, plots, images, long lines, and page breaks are readable
and that no requested output is missing.

## 6. Back up your work

The repository deliberately does not track `student-work/` or `submissions/`.
Course updates will not overwrite those folders, but Git will not back them up
either.

Regularly copy `student-work/` to a secure backup location approved for your
coursework. Do not rely on the generated PDF as the only copy of your notebook.

## Detailed help

- [Complete installation guide](https://github.com/jlinderoth/isye524-students-julia/blob/main/docs/installation.md)
- [Assignment files, images, and backups](https://github.com/jlinderoth/isye524-students-julia/blob/main/docs/assignments.md)
- [PDF export and troubleshooting](https://github.com/jlinderoth/isye524-students-julia/blob/main/docs/pdf-export.md)
- [Homework 0 instructions](https://github.com/jlinderoth/isye524-students-julia/blob/main/assignments/hw00/README.md)
