# Diet example data

Use these files with
[04-McDonaldsDiet-CSV.ipynb](../notebooks/04-McDonaldsDiet-CSV.ipynb).
Change `dataset_filename` in the notebook's first code cell to choose a file,
then run all cells again:

- `mcdonalds.csv`: the original classroom data, with 9 foods and 7 nutrients.
- `diet-synthetic.csv`: generated example data, with 100 fictional foods and
  20 fictional nutrients. All amounts use arbitrary units.

Both files use the same layout:

| Row | `Nutrient` column | `Required` column | Each food column |
| --- | --- | --- | --- |
| Header | `Nutrient` | `Required` | Unique food name |
| First data row | `Cost` | Empty | Cost per serving |
| Remaining rows | Unique nutrient name | Minimum required | Amount per serving |

Costs are positive. Nutrient amounts and minimums are nonnegative. Each nutrient
minimum uses the same units as the amounts in its row. Food quantities are
continuous, and every nutrient constraint is a lower bound.

The McDonald's file preserves all names and numerical values from the original
`isye524-julia/notebooks/mcdonalds.csv`. Its previously empty first-column header
is labeled `Nutrient`; the file uses UTF-8 without a byte-order mark and LF line
endings.

The synthetic file is generated with Julia's `MersenneTwister(524)`. Costs range
from 1.00 to 12.00, and nutrient coefficients range from 0 to 60, with many zeros.
Each minimum is 60% of the total supplied by one serving of each of the first
20 foods, rounded down. Each nutrient has a positive coefficient among those
foods, so that reference menu satisfies every minimum. Positive costs and
nonnegative serving quantities give the minimization problem a finite lower
bound.

Students use the published CSV directly. Maintainers can regenerate it with
the course's Julia 1.12 environment, from the repository root:

```text
julia --startup-file=no --project=. scripts/generate_synthetic_diet.jl
```

This command overwrites `data/diet-synthetic.csv`. Run the class-example tests
after regenerating it:

```text
julia --startup-file=no --project=. test/example_notebooks.jl
```
