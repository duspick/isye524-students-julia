# Homework 06: Network duality and integer production

Due **Monday, October 26, 2026, at 11:59 p.m. (Madison time)**.

## Files and getting started

- `hw06.ipynb`: the assignment, supplied network data, and response areas.
  The network figure is embedded in the notebook; no separate data files are required.
- `README.md`: this overview; `README.html` contains the same instructions for Canvas.

Follow [Assignments and PDF Submission](https://github.com/jlinderoth/isye524-students-julia/blob/main/docs/canvas-assignment-workflow.md) for updating, copying, exporting, and backing up your work.

In VS Code, use **Tasks: Run Task** to run **ISyE 524: Update course repository**, then **ISyE 524: Start an assignment from its template**, entering **`hw06`**. Open **`student-work/hw06/hw06.ipynb`** and select the Julia 1.12 kernel. An existing working copy will not be overwritten. Later course updates do not automatically update your personal copy.

## Complete HW06

Complete all three problems:

1. **Taste of Madison — the shortest-path dual:** derive and solve the node-potential dual of the HW05 restaurant routing LP. Interpret feasible potentials as distance bounds and use a route and complementary slackness to certify optimality. Explain why optimal potentials need not give exact shortest distances at every intermediate node.
2. **Maximum flow — a minimum-cut certificate:** derive the dual for the HW05 six-node network. Check a supplied feasible flow, construct a complementary dual solution by hand, and solve the dual in Julia/JuMP. Identify a cut and explain why its capacity certifies both maximum flow and minimum cut.
3. **Campus Awards — production in whole batches:** formulate and solve an easy two-product IP. Compare its optimum with the LP relaxation, then check the feasibility and quality of nearest-integer and rounded-down plans.

All HW05 network data needed for Problems 1–2 are repeated in the notebook. Implement the **dual LPs** in those problems; no primal reimplementation or graph-search algorithm is required. Use free node potentials, continuous nonnegative capacity multipliers where needed, and the supplied notation. Only Problem 3(a) requires integer variables. The computational work uses Julia/JuMP and HiGHS from the course environment. Write each formulation before its implementation, check solver status and solution availability before reading values, and report the requested results with units.

For every written part, type LaTeX mathematics in Markdown or insert a clear photograph/scan of handwritten work. Keep each answer and its reasoning together, label subparts, and do not duplicate handwritten work in typed form. Implementations belong in code cells. The notebook explains image attachments and relative paths; see [Images and handwritten work](https://github.com/jlinderoth/isye524-students-julia/blob/main/docs/assignments.md#images-and-handwritten-work).

AI tools may help debug your own code, explain syntax or error messages, and critique your work. They should not replace constructing your formulation, implementation, or written solution. End with the required **collaboration and LLM-use statement**: name collaborators and tools/models, identify the specific assistance, explain how it helped you learn, and describe how you checked it. Explicitly state if you worked alone or used no LLM.

## Submit

Run the notebook from top to bottom, check for errors, and save it with results visible. Export with the course PDF task appropriate to your TeX installation. Inspect **`submissions/hw06.pdf`**, including mathematics, the network figure, tables, outputs, and handwritten images. Upload that **single PDF to Gradescope** and mark which PDF pages belong to each problem. **You will not receive full marks unless you do.**

Keep a separate backup of `student-work/hw06/`, including the notebook and any external images. Git does not back up that folder.
