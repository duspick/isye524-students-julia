# Assignment files, images, and backups

Follow [Assignments and PDF Submission](canvas-assignment-workflow.md) for the
standard update, assignment-copy, notebook, export, and submission sequence.
This page provides additional detail about how course files are separated, how
to include images, and how to protect your work.

The repository separates instructor-published templates from student work:

```text
assignments/       Templates and starter files published by the instructor
student-work/      Your personal working copies (not tracked by Git)
submissions/       Generated PDFs for Gradescope (not tracked by Git)
```

## Start an assignment

First update the course repository. In VS Code, open the Command Palette,
select **Tasks: Run Task**, and run:

```text
ISyE 524: Update course repository
```

Then run:

```text
ISyE 524: Start an assignment from its template
```

Enter the assignment name announced by the instructor. For Homework 0, enter
`hw00`. The task copies the complete `assignments/hw00/` directory to
`student-work/hw00/` and prints the notebook path to open. The task refuses to
overwrite an existing student-work directory.

If the task says that student work already exists, nothing was lost or
overwritten. Open the existing assignment folder under `student-work/` and
continue there.

Do not work directly in `assignments/`. Keeping that tracked template unchanged
allows later course updates to arrive without conflicting with your answers.

The equivalent terminal command is:

```text
julia --startup-file=no --project=. scripts/start_assignment.jl hw00
```

## Images and handwritten work

For a handwritten model, save a clear, cropped image as PNG or JPEG. Avoid HEIC,
whose support varies by platform.

The simplest method is to embed the image in the notebook:

1. Edit a Markdown cell in VS Code.
2. Drag the PNG or JPEG into the cell.
3. Select **Insert Image as Attachment**.

VS Code inserts Markdown similar to:

```markdown
![Handwritten mathematical model](attachment:model.png)
```

The image is stored inside the notebook and will travel with it. Notebook-output
cleaning removes code results but must preserve Markdown attachments.

For several large images, create an `images/` directory beside the working
notebook instead:

```text
student-work/hw00/
├── hw00.ipynb
└── images/
    └── model.png
```

Reference the image from a Markdown cell with a path relative to the notebook:

```markdown
![Handwritten mathematical model](images/model.png){width=80%}
```

Both forms are included by the repository's Quarto PDF export workflow without
additional Julia packages. See
[Exporting a notebook to PDF](pdf-export.md) if an image is missing from the
generated PDF.

## Back up student work

`student-work/` is intentionally ignored by Git so course updates cannot
overwrite or conflict with assignment answers. Consequently, this repository
is not a backup for that directory. Regularly copy your `student-work/` folder
to a secure backup location approved for your coursework.

Do not rely on the generated Gradescope PDF as the only copy of your notebook.
