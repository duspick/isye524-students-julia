# Homework 04: Fitting, network flow, and project scheduling

Due **Monday, October 5, 2026, at 11:59 p.m. (Madison time)**.

## Files and getting started

- `hw04.ipynb`: the assignment notebook, supplied data/code, and response areas.
- `data/regression-large.csv`: the fixed 1,200-equation, 60-coefficient instance for Problem 1(c). Keep the `data/` directory beside the notebook.
- `README.md`: this overview; `README.html` contains the same instructions for Canvas.

Follow [Assignments and PDF Submission](https://github.com/jlinderoth/isye524-students-julia/blob/main/docs/canvas-assignment-workflow.md) for updating, copying, exporting, and backing up your work.

In VS Code, use **Tasks: Run Task** to run **ISyE 524: Update course repository**, then **ISyE 524: Start an assignment from its template**, entering **`hw04`**. Open **`student-work/hw04/hw04.ipynb`** and select the Julia 1.12 kernel. The task copies the complete assignment, including its CSV file. If your working copy already exists, open it and continue; it will not be overwritten. Later course updates do not automatically update your personal copy.

## Complete HW04

Complete all three problems:

1. **Fitting equations when they do not agree:** formulate minimum total absolute error and minimum worst absolute error as LPs; solve a small instance and the larger CSV instance; compare both error measures for both fits.
2. **Minimum-cost distribution through a network:** formulate and solve a ten-node, sixteen-arc flow problem; report shipments and verify node balances and capacities.
3. **Stadium building:** formulate and solve for the minimum completion time; report a feasible start/finish schedule and a critical path that certifies optimality.

The assignment uses piecewise-linear, minimax, network-flow, and project-scheduling material associated with Lectures 8–9. Use continuous variables throughout and Julia/JuMP with HiGHS. The supplied CSV-loading cell uses CSV.jl and DataFrames.jl from the course environment.

Write each formulation before implementing it. Check the solver status and your solution, and explain the decisions in context. For the large regression instance, report the requested summaries rather than printing the entire matrix, model, or residual vector. All supplied cells run without completed answers.

For every written part, type LaTeX mathematics in Markdown or insert a clear photograph/scan of handwritten work. Keep the answer and reasoning together, label subparts, and do not duplicate handwritten work in typed form. Implementations belong in code cells. The notebook explains image attachments and relative paths; see [Images and handwritten work](https://github.com/jlinderoth/isye524-students-julia/blob/main/docs/assignments.md#images-and-handwritten-work).

AI tools may help debug your own code, explain syntax or error messages, and critique your work. They should not replace constructing your formulation, implementation, or written solution. End with the required **collaboration and LLM-use statement**: name collaborators and tools/models, identify the specific assistance, explain how it helped you learn, and describe how you checked it. Explicitly state if you worked alone or used no LLM.

## Submit

Run the notebook from top to bottom, check for errors, and save it with results visible. Export with the course PDF task appropriate to your TeX installation. Inspect **`submissions/hw04.pdf`**, including equations, tables, outputs, and handwritten images, then upload that **single PDF to Gradescope** and mark which PDF pages belong to each problem. **You will not receive full marks unless you do.** Do not submit the supplied CSV as a separate answer.

Keep a separate backup of `student-work/hw04/`, including the notebook, CSV file, and any external images. Git does not back up that folder.
