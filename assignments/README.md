# Assignment templates

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
`data/`. Use relative paths for Markdown images. Before publishing a template,
clear all code-cell outputs and execution counts while preserving any Markdown
attachments.
