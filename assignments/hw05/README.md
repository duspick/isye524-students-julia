# Homework 05: Shortest paths, maximum flow, and duality

Due **Monday, October 12, 2026, at 11:59 p.m. (Madison time)**.

## Files and getting started

- `hw05.ipynb`: the assignment, supplied data/loading code, and response areas.
- `data/roads.csv`: the fixed 900-intersection, 2,914-arc road network for Problem 1(c). Keep the `data/` directory beside the notebook.
- `README.md`: this overview; `README.html` contains the same instructions for Canvas.

Follow [Assignments and PDF Submission](https://github.com/jlinderoth/isye524-students-julia/blob/main/docs/canvas-assignment-workflow.md) for updating, copying, exporting, and backing up your work.

In VS Code, use **Tasks: Run Task** to run **ISyE 524: Update course repository**, then **ISyE 524: Start an assignment from its template**, entering **`hw05`**. Open **`student-work/hw05/hw05.ipynb`** and select the Julia 1.12 kernel. The task copies the complete assignment, including the CSV file. If your working copy already exists, open it and continue; it will not be overwritten. Later course updates do not automatically update your personal copy.

## Complete HW05

Complete all three problems, covering Lectures 9–10:

1. **Taste of Madison and a larger road network:** specialize the standard minimum-cost network flow (MCNF) formulation and solve a shortest path; compare with choosing the cheapest outgoing arc; reuse the model on the larger supplied network. For the larger instance, report only the minimum travel time and number of road segments in an optimal route.
2. **Maximum flow and capacity upgrades:** reuse the same MCNF model with a feedback arc and suitable arc costs, solve the six-node network, and compare three independent capacity upgrades. Compare each throughput increase with the upgraded arc's unused capacity (original capacity minus its flow in the original optimal solution). Explain their effects using capacities and node balances.
3. **Duality — bounds and optimality certificates:** write the dual using `y_1` and `y_2`, prove the weak-duality inequality, use feasible points to bound the optimum, and use complementary slackness to find a dual solution complementary to a given primal solution. Check feasibility and matching objective values to certify optimality, then obtain a new certificate after increasing the second resource limit to 12. No code is required for this problem.

For Problems 1–2, use the standard [minimum-cost network flow notebook (`mcnf.ipynb`)](https://github.com/jlinderoth/isye524-students-julia/blob/main/notebooks/12-mcnf.ipynb), found at `notebooks/12-mcnf.ipynb` in the student repository. Write the specialization for each application, then adapt and reuse that model code throughout both problems. Keep its minimum-cost objective, outflow-minus-inflow balances, and lower/upper bounds; change the input data for shortest paths, the larger network, maximum flow, and capacity upgrades. Explain how the minimum-cost objective relates to throughput in Problem 2. Use continuous variables and Julia/JuMP with HiGHS. Check solver status before reading solution values. The supplied CSV-loading cell uses CSV.jl and DataFrames.jl from the course environment. Use the fixed road data rather than generating a new instance. All supplied cells run without completed answers.

For every written part, type LaTeX mathematics in Markdown or insert a clear photograph/scan of handwritten work. Keep each answer and its reasoning together, label subparts, and do not duplicate handwritten work in typed form. Implementations belong in code cells. The notebook explains image attachments and relative paths; see [Images and handwritten work](https://github.com/jlinderoth/isye524-students-julia/blob/main/docs/assignments.md#images-and-handwritten-work).

AI tools may help debug your own code, explain syntax or error messages, and critique your work. They should not replace constructing your formulation, implementation, or written solution. End with the required **collaboration and LLM-use statement**: name collaborators and tools/models, identify the specific assistance, explain how it helped you learn, and describe how you checked it. Explicitly state if you worked alone or used no LLM.

## Submit

Run the notebook from top to bottom, check for errors, and save it with results visible. Export with the course PDF task appropriate to your TeX installation. Inspect **`submissions/hw05.pdf`**, including mathematics, the network figure, outputs, and handwritten images. Upload that **single PDF to Gradescope** and mark which PDF pages belong to each problem. **You will not receive full marks unless you do.** Do not submit the supplied CSV as a separate answer.

Keep a separate backup of `student-work/hw05/`, including the notebook, CSV file, and any external images. Git does not back up that folder.
