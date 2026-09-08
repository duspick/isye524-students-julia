# Updating course packages and solvers

Complete this task whenever the instructor announces new Julia packages or
solvers. Use your existing course repository and Julia 1.12 installation.

## Student task: install and check a course environment update

1. Save your notebooks in `student-work/` and keep your usual backup.
2. Open the `isye524-students-julia` repository root in VS Code.
3. Open the Command Palette, select **Tasks: Run Task**, and run:

   ```text
   ISyE 524: Update course repository
   ```

   Wait for the task to finish successfully. It downloads the latest course
   files, installs the published package versions, and precompiles them. This
   can take several minutes and requires internet access for new downloads.
4. Run **Tasks: Run Task** again and select:

   ```text
   ISyE 524: Run environment check
   ```

   All tests must pass. The current check prints the HiGHS result
   `x = 3.6, y = 2.8, objective = 22.0`.
5. Restart each open Julia notebook kernel and any running Julia REPL before
   continuing. Select Julia 1.12 and rerun the notebook from the beginning.
6. Complete any solver-specific setup and verification supplied with the
   instructor's announcement. A solver that requires a license needs that
   license configured before its example can solve a model.

You are finished when the update succeeds, the environment check passes, and
any example supplied for the new package or solver runs successfully. If the
instructor requests evidence, submit the check output and the new example's
result through the assignment's stated submission method.

The equivalent commands, run one at a time in a VS Code terminal at the
repository root, are:

```text
git pull --ff-only
julia --startup-file=no --project=. scripts/setup.jl
julia --startup-file=no --project=. test/smoke.jl
```

Stop if a command fails; resolve that error before running the next command.
If you already pulled the updated course files, the **Set up / refresh Julia
environment** task is enough to install their packages before running the check.

Do not run `Pkg.add` or `Pkg.update` yourself in the course environment, edit
`Project.toml` or `Manifest.toml`, or put package-installation commands in your
notebook. The instructor publishes the package versions for everyone.

## If the update fails

- **Git reports local changes:** preserve a separate copy of your changes and
  ask course staff for help resolving the update. Do not delete your work or
  run `git reset --hard`. Personal answers belong in `student-work/`.
- **A download fails:** restore your internet connection, then rerun **Set up /
  refresh Julia environment** and the environment check after the pull succeeds.
- **A notebook cannot find a newly announced package:** confirm the update
  succeeded, restart its kernel, and check that its active project is the
  repository's `Project.toml`. Run `Base.active_project()` in a Julia cell to
  see the path.
- **A solver reports a license error:** follow the instructor's instructions
  for that solver. Repeating the general setup task does not obtain a license.

If you need help, provide course staff with your operating system, Julia
version, the task name, and the full error message. Remove license keys or
credentials before sharing output.
