# Homework 03: Blending and multiperiod planning

Due **Monday, September 28, 2026, at 11:59 p.m. (Madison time)**. Covers blending, inventory balances, staffing, and backlogging from Lectures 6–7.

## Files and getting started

- `hw03.ipynb`: the assignment notebook, with all problem data, supplied code, and response areas. No external data files are needed.
- `README.md`: this overview.

Follow [Assignments and PDF Submission](https://github.com/jlinderoth/isye524-students-julia/blob/main/docs/canvas-assignment-workflow.md) for the update, copy, export, and backup workflow.

Use **Tasks: Run Task** in VS Code to run **ISyE 524: Update course repository**, then **ISyE 524: Start an assignment from its template**, entering **`hw03`**. Open **`student-work/hw03/hw03.ipynb`** and select the Julia 1.12 kernel. If your working copy already exists, open it and continue; the copy task will not overwrite it. Later course updates do not automatically update your personal assignment copy.

All required Julia packages are already included in the course environment.

## Complete HW03

Complete all three problems:

1. **Alloy Blending:** formulate and solve the seven-material, three-element LOSE instance; check the blend and explain the relationship between minimum and exact delivery.
2. **So Much Grading!:** plan hiring, retirement, and grading over five months, allowing unfinished work to carry over until the final deadline.
3. **The Goblet of Wine:** plan six products over twelve weeks under shared labor, machine, and storage limits, then allow backlogging and compare the plans.

Write each mathematical formulation before implementing it in Julia/JuMP with HiGHS. Define variables and units, include initial and final conditions, check your computed solution, and interpret the results. Use continuous variables throughout, including grader equivalents and fractional batches. Part 1(c) is written only. All supplied data cells run without completed student answers.

For every written part, type LaTeX mathematics in Markdown or insert a clear photograph/scan of handwritten work. Keep answers and reasoning together and label subparts; no duplicate transcription is required. Implementations belong in code cells. The notebook explains image attachments and relative paths; see [Images and handwritten work](https://github.com/jlinderoth/isye524-students-julia/blob/main/docs/assignments.md#images-and-handwritten-work).

AI tools may help debug your own code, explain syntax or error messages, and critique your work. They should not replace constructing your formulation, implementation, or written solution. End the notebook with the required **collaboration and LLM-use statement**: name collaborators and tools/models, describe the specific assistance, how it helped you learn, and how you checked it. Explicitly state if you worked alone or used no LLM.

## Submit

Run the notebook from top to bottom, check for errors, and save it with results visible. Export using the course PDF task appropriate to your TeX installation. Inspect **`submissions/hw03.pdf`**, including all equations, tables, outputs, and handwritten images, then upload that **single PDF to Gradescope** and match pages to questions.

Keep a separate backup of `student-work/hw03/`, including the notebook and any external images. Git does not back up that folder.
