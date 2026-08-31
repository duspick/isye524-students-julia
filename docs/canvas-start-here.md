# ISyE 524: Start Here with Julia and JuMP

This page gives you the shortest path to a working course environment. The
[public ISyE 524 GitHub repository](https://github.com/jlinderoth/isye524-students-julia)
is the authoritative source for current instructions and course files.

Allow time for the first setup: Julia must download and prepare the course
packages. Later starts will be much faster.

## 1. Choose your computer setup

Choose one of the following paths before installing anything.

### Windows: native Windows or WSL

You may use either native Windows or Windows Subsystem for Linux (WSL). Do not
mix the two environments.

- **Native Windows:** install and run the Windows versions of the required
  command-line programs. Open the repository in a normal VS Code window.
- **WSL:** install VS Code on Windows and use its WSL extension. Install and run
  the required command-line programs inside your Linux distribution. Clone the
  repository from a WSL terminal and open it in a VS Code window whose
  lower-left corner says **WSL**.

Follow the Windows or WSL sections of the
[complete installation guide](https://github.com/jlinderoth/isye524-students-julia/blob/main/docs/installation.md).

### macOS

Use the macOS versions of the required programs. Follow the macOS sections of
the
[complete installation guide](https://github.com/jlinderoth/isye524-students-julia/blob/main/docs/installation.md).

## 2. Confirm the required programs

Before cloning the course repository, confirm that you have:

- Git;
- Julia 1.12.x, preferably installed with Juliaup; and
- Visual Studio Code.

The complete installation guide provides the commands and official download
links for each operating system. Do not reinstall a program when its
verification command already works.

## 3. Clone and open the course repository

Run these commands in an operating-system terminal, not at a `julia>` prompt:

```text
git clone https://github.com/jlinderoth/isye524-students-julia.git
cd isye524-students-julia
code .
```

The repository is public, so cloning it does not require a GitHub account. Do
not run `git clone` with `sudo`.

If the `code` command is unavailable, open VS Code normally, select
**File: Open Folder**, and choose the `isye524-students-julia` folder. Always
open the repository root, not an individual notebook or subfolder.

## 4. Install the recommended VS Code extensions

Accept VS Code's prompt to install the workspace recommendations. If the prompt
does not appear, open the Command Palette and select
**Extensions: Show Recommended Extensions**.

Install all three recommendations:

- Julia;
- Jupyter; and
- Quarto.

## 5. Set up and test Julia

In VS Code, open the Command Palette:

- Windows or WSL: **Ctrl+Shift+P**
- macOS: **Command+Shift+P**

Select **Tasks: Run Task**, then run these tasks in order:

```text
ISyE 524: Set up / refresh Julia environment
ISyE 524: Run environment check
```

The first task may take several minutes. The environment check must finish with
all tests passing.

These are VS Code tasks, not Julia commands. If your terminal shows a `julia>`
prompt, enter `exit()` before running terminal commands.

## 6. Run the installation notebook

In VS Code, open:

```text
notebooks/00-check-installation.ipynb
```

If prompted for a notebook kernel, choose Julia 1.12, then select **Run All**.
A successful run displays:

- the active Julia version and course project;
- the optimal solution `(x, y) = (3.6, 2.8)` and objective value `22.0`;
- a two-row results table;
- a plot of the feasible region and optimal solution; and
- rendered Markdown mathematics.

If something does not work, return to the
[complete installation guide](https://github.com/jlinderoth/isye524-students-julia/blob/main/docs/installation.md)
and check each step in order.

## 7. Start Homework 0

After the installation notebook succeeds, open the Command Palette, select
**Tasks: Run Task**, and run:

```text
ISyE 524: Update course repository
ISyE 524: Start an assignment from its template
```

Enter `hw00` when the second task asks for the assignment name. Work only in the
new `student-work/hw00/` folder; do not edit the template under
`assignments/hw00/`.

Follow the authoritative
[Homework 0 instructions](https://github.com/jlinderoth/isye524-students-julia/blob/main/assignments/hw00/README.md).
Work through `julia-tutorial.ipynb` first, then complete `hw00.ipynb`.

Before submitting, use the
[assignment and PDF workflow](https://github.com/jlinderoth/isye524-students-julia/blob/main/docs/canvas-assignment-workflow.md).

## If you need help

When asking for course help, include:

- whether you chose native Windows, WSL, or macOS;
- the numbered step and VS Code task you were running;
- the complete error message, not only its final line; and
- the output of `git --version`, `julia --version`, and, if installed,
  `quarto --version` from the VS Code integrated terminal.

Never include a password, access token, or other secret in a screenshot or
message.
