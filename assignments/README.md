# Assignment templates

This page is for course maintainers who publish assignment templates. Students
should not edit anything under `assignments/`; students should follow
[Assignments and PDF Submission](../docs/canvas-assignment-workflow.md) to make
and use a personal copy under `student-work/`.

Each published assignment gets its own tracked directory with a stable,
lowercase identifier such as `hw01`:

```text
assignments/
└── hw01/
    ├── hw01.ipynb
    ├── README.md
    └── starter-files/
```

Students should not edit files in this directory. The **ISyE 524: Start an
assignment from its template** VS Code task copies the complete directory to
`student-work/hw01/` and refuses to overwrite an existing copy.

For predictable PDF names, give the primary notebook the same name as the
assignment identifier: `assignments/hw01/hw01.ipynb` exports as
`submissions/hw01.pdf` after it is copied and completed.

Keep all files that must travel with a starter notebook inside its assignment
directory, except shared course datasets that intentionally live under
`data/`. Use relative paths for Markdown images.

Each assignment-specific `README.md` should:

- briefly identify the included files and which file students submit;
- link to [Assignments and PDF Submission](../docs/canvas-assignment-workflow.md)
  for the standard update, copy, export, and backup workflow; and
- describe only requirements that are special to that assignment.

Before publishing a template, clear all code-cell outputs and execution counts
while preserving any Markdown attachments. Test the complete student copy and
PDF-export path. The maintainer pre-commit hook performs notebook cleaning
automatically; see [Maintainer workflow](../docs/maintainers.md).

Add new assignments to the root README and to `test/assignment_notebooks.jl`
so CI executes their supplied starter code. Check that required files travel
with the student copy and that data paths work both beside the notebook and
from the repository root. Student implementation cells may remain empty or
contain comments; keep solution checks out of published starter notebooks.
