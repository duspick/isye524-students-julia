# Help with course updates

Use **Tasks: Run Task > ISyE 524: Update course repository** to download new
course files and refresh the Julia environment. The **Pull latest course
files** task performs just the download step.

## Why Git sometimes stops

Git protects local changes. If an incoming course update would overwrite a
file you changed, the pull stops and lists the affected files. This can happen
with `.vscode/settings.json` in older clones that still track that file.
Saving a course notebook after running it can also change its outputs and
metadata, even if you did not edit any code.

The ordinary update task does not discard or automatically stash your changes.
Personal assignments belong in `student-work/`, which Git ignores.

## Reset course files with an automatic backup

If saved notebook outputs, local edits, or local commits prevent an ordinary
update, use this recovery task to return the course files to the instructor's
published versions:

```text
ISyE 524: Reset course files to latest (with backup)
```

1. **Save and close your notebooks and other edited course files.** Stop any
   running notebook cells first. The task can back up saved files only.
2. Open **Tasks: Run Task** and select the reset task.
3. Select **RESET** in the prompt. **Cancel** is the default.
4. Wait for the course reset and Julia environment refresh to finish. The
   terminal prints the backup's full location.
5. Restart your notebook kernels and reopen the updated course notebooks.

The task downloads the latest `origin/main` from the official course
repository, completes a backup, and then replaces tracked course files with
that downloaded version. It does not merge or reapply your old notebook edits.
Code, notes, and outputs from your previous saved notebooks remain in the
backup. A failed download or backup stops the task before it resets files.

Backups are created **beside the repository**, with a date, time, and unique
suffix. For example:

```text
Documents/
  isye524-students-julia/
  isye524-students-julia-backup-20260917-143000-AbCdEf/
    README.txt
    working-tree/notebooks/...
    repository.bundle
    staged.patch
    unstaged.patch
    status.txt
```

`working-tree/` contains saved copies of tracked files and any local files
that incoming course files could overwrite. Open those copies to retrieve
notes or code, and copy notebooks you want to keep into `student-work/` with
any data or images they need. `repository.bundle` preserves Git history,
including local commits; the patches preserve staged and unstaged changes.
Ask course staff for help restoring history or staged changes.

The task leaves `student-work/`, `submissions/`, and other nonconflicting
untracked files in place. It preserves `.vscode/settings.json`, including in
older clones where that file is still tracked. It refuses to reset if the
published version would overwrite a protected personal path, or if Git is
already tracking files under `student-work/` or `submissions/`. It never runs
`git clean`. Continue your regular backups of personal work; the course reset
backup is not a complete backup of those personal folders.

If setup fails after the reset, the downloaded course files and backup remain
available. Rerun **ISyE 524: Set up / refresh Julia environment** rather than
resetting again. Keep backups until you are sure you have recovered any work
you need; the task never deletes old backups.

The terminal equivalent, **after saving and closing your notebooks**, is:

```text
julia --startup-file=no scripts/reset_course.jl RESET
```

If this task is missing, your clone predates its introduction. Follow the
manual recovery instructions below or ask course staff for help with the
first update. After that update, the new task will be available.

## One-time migration for `.vscode/settings.json`

The repository now ignores `.vscode/settings.json`, so you can keep personal
workspace preferences without blocking future updates. Shared tasks and
extension recommendations are still tracked; the settings file is optional.

Older clones must first receive the update that removes this file from Git.
If your settings file is unchanged, Git removes the old copy during that
update. If it has local changes, Git may stop to protect them. Use these steps
when Git says your changes to `.vscode/settings.json` would be overwritten or
removed by the update:

1. Save any open settings editor. In VS Code's Explorer, copy
   `.vscode/settings.json` into `student-work/` and rename the copy to
   `vscode-settings-backup.json`. Create `student-work/` if needed. Use a new
   name if that backup already exists, and open the copy to confirm that your
   settings were saved. If Source Control shows a separate **Staged Changes**
   version of the file, preserve any settings unique to that version too.
2. Close the repository's `.vscode/settings.json` editor. In **Terminal: New
   Terminal**, at the repository root (not at a `julia>` prompt), run:

   ```text
   git restore --source=HEAD --staged --worktree -- .vscode/settings.json
   ```

   This replaces the local and staged copies of **only this file** with the
   version from your current Git commit. Run it only after checking your
   backup; your settings changes will now be in that backup.
3. Run **ISyE 524: Update course repository** again. If Git lists other files,
   preserve those changes too and follow the next section.
4. After the update succeeds, copy your backup back to
   `.vscode/settings.json`. It is now a personal, ignored file. Keep the
   backup as well; Git will no longer back up this settings file.

If you do not have a settings file, you can optionally copy
`.vscode/settings.example.json` to `.vscode/settings.json` for the suggested
course defaults. Do not overwrite an existing personal settings file.

You can also use the **User** tab in VS Code Settings for preferences that
should apply across projects. The **Workspace** tab changes the local
`.vscode/settings.json`, which is safe to customize after this migration. See
[VS Code's settings guide](https://code.visualstudio.com/docs/configure/settings).

## If Git lists a notebook or another course file

Use the reset task above to back up and replace course files automatically.
If that task is not yet available, the manual alternative is:

Copy every affected file you want to keep into `student-work/` or another
backup location before changing anything in Source Control. Include related
images and data if they are needed for your work.

After verifying the copies, use VS Code's Source Control view to discard
changes to **only the backed-up files** you want to return to the course
versions, then rerun the update task. Ask course staff for help if a file is
staged or you are unsure what to keep. Do not select **Discard All Changes**
or run `git reset --hard` yourself; the named reset task performs the backups
and preservation checks first.

To keep notes or modified examples, work on copies under `student-work/`.
Start assignments with **ISyE 524: Start an assignment from its template**.

## If the error is different

- **Cannot fast-forward / branches have diverged:** your clone may contain
  local commits. The reset task preserves that history in its backup and
  returns the active branch to the published course version. Ask course staff
  for help if you want to keep developing those commits instead.
- **Unmerged files / merge or rebase in progress:** ask course staff for help
  completing or undoing that operation before attempting another update.
- **Reset rejects the remote, upstream, or checkout:** the reset task supports
  full, ordinary clones tracking the official repository's `origin/main`.
  Ask course staff about forks, shallow/sparse clones, or submodules.
- **Cannot reach GitHub / download failed:** check your internet connection
  and retry the update. If the pull succeeded but Julia package setup failed,
  rerun **Set up / refresh Julia environment**.

Include your operating system, task name, and the full error message when
asking for help. Remove credentials before sharing output.

## For course staff

Students already blocked by local changes cannot download this guide through
the failing update task. Share the
[online guide](https://github.com/jlinderoth/isye524-students-julia/blob/main/docs/course-updates.md)
in Canvas or send them the settings recovery steps directly after publishing.

Publish the removal of `.vscode/settings.json` together with the `.gitignore`
change and the optional `.vscode/settings.example.json`. Adding an ignore
rule alone does not stop tracking a committed file; see the
[Git ignore documentation](https://git-scm.com/docs/gitignore). Keep tasks and
extension recommendations tracked, and do not force-add personal settings.

Avoid automatically stashing and reapplying all student changes during course
updates. Reapplying a stash can itself conflict, including in notebooks; see
the [Git pull documentation](https://git-scm.com/docs/git-pull#Documentation/git-pull.txt---autostash).
