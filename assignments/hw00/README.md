# Homework 0: Julia and JuMP setup

Homework 0 verifies the complete course workflow before later optimization
assignments begin. It contains two notebooks:

- `julia-tutorial.ipynb` is the guided introduction. Work through it first.
- `hw00.ipynb` contains the exercises and is the notebook submitted to
  Gradescope.

Use [Assignments and PDF Submission](../../docs/canvas-assignment-workflow.md)
for the standard course workflow. The instructions below identify the steps
specific to Homework 0.

## Start the assignment

First run **ISyE 524: Update course repository**. Then run:

```text
ISyE 524: Start an assignment from its template
```

Enter `hw00` when prompted. The task creates `student-work/hw00/` and refuses to
overwrite an existing copy. Make all changes in that student-work copy; do not
edit the template under `assignments/hw00/`.

## Complete and submit the assignment

1. Open `student-work/hw00/julia-tutorial.ipynb`, select the Julia 1.12 kernel,
   enter your name where requested, and run the notebook from top to bottom.
2. Open `student-work/hw00/hw00.ipynb` and complete every requested Markdown and
   code cell.
3. Run all cells in `hw00.ipynb`, check for errors, and save it.
4. With `hw00.ipynb` active, run **ISyE 524: Export active notebook to PDF
   (TinyTeX)** or **ISyE 524: Export active notebook to PDF (system TeX)**,
   according to the LaTeX setup chosen during installation.
5. Open `submissions/hw00.pdf`, inspect every page, and upload that PDF to
   Gradescope. The tutorial notebook is not submitted.

The assignment includes an image-insertion exercise. PNG and JPEG are the most
portable formats. An image inserted as a Markdown attachment is stored inside
the notebook; an image referenced by a relative path must remain inside the
`student-work/hw00/` directory. See
[Assignment files, images, and backups](../../docs/assignments.md) for detailed
image instructions.

Keep a separate backup of `student-work/hw00/`. Student work is intentionally
ignored by Git and is not backed up by repository updates.
