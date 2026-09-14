# Homework 02: LP reformulation, indexed models, and blending

Due **Monday, September 21, 2026, at 11:59 p.m. (Madison time)**. Covers the latter part of Lecture 3, Lecture 4, and introductory blending from Lecture 5.

## Files and getting started

- `hw02.ipynb`: the assignment notebook, including problem statements, supplied code, and response areas.
- `data/products.csv`, `data/methods.csv`, `data/revenues.csv`: the Problem 2 data. Keep the entire `data/` folder beside the notebook.
- `README.md`: this overview.

Follow [Assignments and PDF Submission](https://github.com/jlinderoth/isye524-students-julia/blob/main/docs/canvas-assignment-workflow.md) for the update, copy, export, and backup workflow.

Use **Tasks: Run Task** in VS Code to run **ISyE 524: Update course repository**, then **ISyE 524: Start an assignment from its template**, entering **`hw02`**. Open **`student-work/hw02/hw02.ipynb`** and select the Julia 1.12 kernel. The copy includes the data files. If your working copy already exists, open it and continue; the copy task will not overwrite it. Later course updates do not automatically update your personal assignment copy.

All required Julia packages are already included in the course environment.
The supplied cells run before you fill in your answers; the commented code
cells are places for your implementations. The data loader works from the
repository root or the notebook's folder. Keep HW02's `data/` folder with your
working notebook; these are assignment-specific files.

## Complete HW02

Complete all three problems:

1. Convert LPs to standard form, explain equivalence, verify recovered solutions with JuMP, and justify four LP solution cases.
2. Formulate and solve a general indexed production/processing model using the supplied CSV data, interpret resource use, and explain why independent choices can violate shared capacities.
3. Formulate and solve a steel-blending LP, verify composition requirements, and justify why an optimal delivery is exactly 500 tons.

Write formulations before implementation and include the requested reasoning, units, constraints, and interpretation. Some Problem 1 questions and the final parts of Problems 2 and 3 need no additional code.

For every written part, type LaTeX mathematics in Markdown or insert a clear photograph/scan of handwritten work. Keep answers and reasoning together and label subparts; no duplicate transcription is required. Implementations belong in code cells. The notebook explains image attachments and relative paths; see [Images and handwritten work](https://github.com/jlinderoth/isye524-students-julia/blob/main/docs/assignments.md#images-and-handwritten-work).

AI tools may help debug your own code, explain syntax or error messages, and critique your work. They should not replace constructing your formulation, implementation, or written solution. End the notebook with the required **collaboration and LLM-use statement**: name collaborators and tools/models, describe the specific assistance, how it helped you learn, and how you checked it. Explicitly state if you worked alone or used no LLM.

## Submit

Run the notebook from top to bottom, check for errors, and save it with results visible. Export using the course PDF task appropriate to your TeX installation. Inspect **`submissions/hw02.pdf`**, including all equations, tables, outputs, and handwritten images, then upload that **single PDF to Gradescope** and match pages to questions.

Keep a separate backup of `student-work/hw02/`, including the notebook, data, and any external images. Git does not back up that folder.
