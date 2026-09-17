# Installing the ISyE 524 student environment

For a shorter overview and the path into Homework 0, begin with
[Start Here with Julia and JuMP](canvas-start-here.md). Use this page for the
complete operating-system-specific procedure and troubleshooting details.

This page is documentation, not a Julia program. Do not use **Julia: Execute
Active File** on this page and do not paste its prose into a prompt that says
`julia>`. Run only the commands shown in code boxes, using **Terminal: New
Terminal** in VS Code. If `julia>` is already visible, enter `exit()` first to
return to the operating-system terminal. Repository Markdown files open as
rendered previews by default to prevent this mistake; maintainers can select
**Reopen Editor With: Text Editor** when they need to edit one.

Complete these steps in order before using the course notebooks. Git, Julia,
VS Code, Quarto, and LaTeX are applications installed for your user account or
computer. They are not installed inside this repository. The repository pins
the Julia *packages* used by the course.

An existing installation is supported when its verification command below
works in the VS Code integrated terminal. Do not reinstall a working tool.

## Native Windows or WSL: choose one environment

Windows students may use either native Windows tools or a Linux distribution
under Windows Subsystem for Linux (WSL). Do not mix the two workflows.

- For native Windows, install the Windows versions of Git, Julia, and Quarto,
  then open the repository in a normal VS Code window.
- For WSL, install VS Code on Windows plus Microsoft's WSL extension. Install
  the Linux versions of Git, Julia, and Quarto *inside the WSL distribution*.
  Clone the repository from a WSL terminal and run `code .` there. The lower
  left corner of VS Code must say **WSL: Ubuntu** (or the name of the selected
  distribution). A Windows installation of Julia or Quarto is not available
  to repository tasks running in WSL. See Microsoft's
  [VS Code in WSL guide](https://code.visualstudio.com/docs/remote/wsl) if the
  WSL extension or `code .` is not yet configured.

All Linux commands below also apply inside WSL. Once a repository is open in a
WSL window, **Terminal: New Terminal** opens a Linux shell in that same WSL
distribution.

## 1. Install or verify Git

Open a normal operating-system terminal (PowerShell or Command Prompt on
Windows, Terminal on macOS, or a terminal on Linux) and run:

```text
git --version
```

If this prints a Git version, keep that installation and continue. If the
command is not found, install Git for your operating system:

- **Windows:** install [Git for Windows](https://git-scm.com/install/windows).
  During installation, use the option that makes Git available from the
  command line and third-party applications.
- **macOS:** run `xcode-select --install`. If you already use Homebrew, you may
  instead run `brew install git`.
- **Ubuntu or Debian Linux:** run `sudo apt update`, followed by
  `sudo apt install git`.
- **Fedora Linux:** run `sudo dnf install git`.
- **Other Linux distributions:** use the command listed by the
  [official Git installation guide](https://git-scm.com/install/linux).

Close and reopen the terminal, then confirm that `git --version` works.
VS Code uses the Git installation on the computer; its built-in Git interface
does not install Git. GitHub Desktop alone also does not provide the
command-line Git installation required by the repository tasks.

## 2. Install or verify Julia 1.12

Run:

```text
julia --version
```

If this reports `julia version 1.12.x`, keep that installation and continue.
The installation does not have to be managed by Juliaup, but the `julia`
command must be on `PATH` so VS Code tasks can run it.

For a new installation, use Juliaup, Julia's official installer and version
manager.

### Windows

Run this in PowerShell or Command Prompt:

```text
winget install --name Julia --id 9NJNWW8PVKMN -e -s msstore
```

If the Microsoft Store is unavailable, use the Windows installer linked from
the [official Julia download page](https://julialang.org/downloads/).

### macOS or Linux

Run this in a terminal and follow the installer prompts:

```text
curl -fsSL https://install.julialang.org | sh
```

After installing Juliaup, close and reopen the terminal. On every operating
system, select the supported Julia series with:

```text
juliaup add 1.12
juliaup default 1.12
julia --version
```

The final command must report Julia 1.12.x. The minor-version channel follows
the current 1.12 patch release, so it does not have to be pinned to one patch.

### Keep a different Juliaup default for other work

If another project needs a different default Julia version, do not run
`juliaup default 1.12`. After cloning this repository in Step 4, open a terminal
in the repository root and run:

```text
juliaup add 1.12
juliaup override set 1.12
julia --version
```

The Juliaup directory override selects Julia 1.12 in this repository while
leaving the default used elsewhere unchanged.

## 3. Install VS Code

Install [Visual Studio Code](https://code.visualstudio.com/download). Completely
close VS Code if it was open while installing Git or Julia; a running VS Code
process does not automatically receive later `PATH` changes.

On macOS, the `code` terminal command is optional. To enable it, open the VS
Code Command Palette and run:

```text
Shell Command: Install 'code' command in PATH
```

## 4. Clone and open the repository

If you already have a Git clone of the repository, keep it and skip the clone
command. A fresh clone does not fix a missing Git or Julia installation.

To create a clone, run:

```text
git clone https://github.com/jlinderoth/isye524-students-julia.git
cd isye524-students-julia
code .
```

If `code` is unavailable, open VS Code normally, select **File: Open Folder**,
and choose the `isye524-students-julia` folder. Always open this repository
root, not an individual notebook or a subfolder.

## 5. Verify Git and Julia inside VS Code

In VS Code, select **Terminal: New Terminal** and run:

```text
git --version
julia --version
```

Do not proceed until both commands work and Julia reports version 1.12.x. If a
command works in an external terminal but not here:

1. completely quit every VS Code window;
2. reopen the repository with `code .` from the working external terminal; and
3. run the two checks again in a new VS Code terminal.

For a manually installed or user-local Git or Julia, add the directory
containing its executable to the operating system's `PATH` before starting VS
Code. A VS Code-only `git.path` or `julia.executablePath` setting may help an
extension, but it does not make the executable available to repository tasks.

## 6. Install the recommended VS Code extensions

When VS Code offers to install the workspace's recommended extensions, select
**Install**. The recommendations are:

- Julia
- Jupyter
- Quarto

If the prompt does not appear, open **Extensions: Show Recommended Extensions**
from the Command Palette and install the workspace recommendations. The Quarto
extension does not install the Quarto command-line program used for PDF export.

Personal workspace preferences in `.vscode/settings.json` are ignored by Git.
This file is optional. To use the suggested course defaults, copy
`.vscode/settings.example.json` to `.vscode/settings.json` without overwriting
an existing settings file. These defaults disable Julia startup files for the
VS Code Julia REPL and open Markdown files in preview. Course tasks already
pass `--startup-file=no` themselves and do not require this settings file.

For preferences that should apply across projects, select the **User** tab in
Settings, or use **Preferences: Open User Settings (JSON)** from the Command
Palette. If an older clone reports a settings conflict during an update,
follow the one-time migration in [Help with course updates](course-updates.md).

## 7. Set up and test the Julia environment

Open the Command Palette, select **Tasks: Run Task**, and run these tasks in
order:

```text
ISyE 524: Set up / refresh Julia environment
ISyE 524: Run environment check
```

Do not start **Julia: Start REPL** for this step. A setup task opens in the
Terminal panel, runs to completion, and does not leave a `julia>` prompt. A
message such as ``UndefVarError: `Follow` not defined`` means documentation
prose was accidentally executed in an interactive Julia REPL; enter `exit()`
and run the task above instead.

The first task downloads the versions recorded in `Manifest.toml` and creates
the ignored `student-work/` and `submissions/` directories. The first setup can
take several minutes. The environment check must finish with all tests passing.

Course maintainers should then run this task once in each clone.
**Students are not course maintainers, so should not do this step**

```text
ISyE 524 Maintainer: Enable pre-commit hook
```

Students do not need the maintainer hook because they should not commit changes
to the course repository.

## 8. Install Quarto

The Quarto VS Code extension supplies editor buttons and previews. The separate
Quarto command-line program does the actual conversion from a saved notebook to
LaTeX input, and LaTeX compiles that input into the PDF. Quarto is therefore
required even when a working TeX Live, MacTeX, MiKTeX, or other LaTeX
installation is already present. The VS Code extension, Quarto command-line
program, and one LaTeX distribution are three separate pieces.

### Native Windows

1. Download the current Windows `.msi` from the
   [official Quarto download page](https://quarto.org/docs/download/).
2. Run the installer using its defaults.
3. Completely quit every VS Code window and reopen the repository.

### macOS

1. Download the current macOS `.pkg` from the
   [official Quarto download page](https://quarto.org/docs/download/).
2. Run the installer, then completely quit and reopen VS Code.

### Ubuntu or Debian Linux

1. Download the current Ubuntu/Debian `.deb` from the
   [official Quarto download page](https://quarto.org/docs/download/).
2. Open a terminal in the directory containing the downloaded file. It is
   normally `~/Downloads`.
3. Run the command below, replacing `<version>` with the version in the actual
   filename. Typing `sudo apt install ./quarto-` and pressing Tab can complete
   the filename.

```text
sudo apt install ./quarto-<version>-linux-amd64.deb
```

On an Arm64 Linux computer, use the Arm64 `.deb` and its actual filename.
After installation, the downloaded `.deb` is no longer needed. Remove it from
the download directory rather than copying or leaving it in the course
repository.

### WSL with Ubuntu or Debian

Use the Linux `.deb`, not the Windows `.msi`. Either download it within WSL or
download it with the Windows browser and access the Windows Downloads folder
from WSL:

```text
ls /mnt/c/Users
cd /mnt/c/Users/<Windows-user-name>/Downloads
sudo apt install ./quarto-<version>-linux-amd64.deb
```

Replace both placeholders with the names on the computer. Then return to the
repository directory and run `code .`. Confirm that the reopened window says
**WSL** in the lower-left corner. Quarto, Julia, the Julia extension, and the
Quarto extension all run on the Linux/WSL side in this window.

APT may print a notice that the local `.deb` was downloaded "unsandboxed as
root" because the `_apt` user could not access its directory. If the output
says `Setting up quarto` and `quarto --version` works afterward, installation
succeeded; the notice is not an error. The downloaded `.deb` can then be
removed.

### Other Linux distributions or a no-sudo Linux install

Use Quarto's official
[user-local Linux tarball instructions](https://quarto.org/docs/download/tarball.html).
They extract Quarto under `~/opt` and put a link to its executable under
`~/.local/bin`; no root access is required. Make sure `~/.local/bin` is on
`PATH`, then completely restart VS Code.

### Verify the command-line program

In a new VS Code integrated terminal, run:

```text
quarto --version
```

This command must work in the same native or WSL window used for the course.
Then run this VS Code task:

```text
ISyE 524: Check PDF export tools
```

The repository-owned check reports the executable path and version. If Quarto
is absent, it prints instructions for the detected operating system instead of
failing with only “command not found.”

## 9. Choose one LaTeX option

Quarto needs LaTeX to create Gradescope PDFs. Existing and Quarto-managed
installations are both supported. The two options below choose which LaTeX
distribution Quarto uses; neither option replaces Quarto itself.

### Option A: use an existing local or system LaTeX installation

Keep an existing TeX Live, MacTeX, MiKTeX, or user-local TeX installation if
this works in the VS Code integrated terminal:

```text
lualatex --version
```

Do not install Quarto-managed TinyTeX. When exporting, use:

```text
ISyE 524: Export active notebook to PDF (system TeX)
```

That task tells Quarto not to select its managed TinyTeX and disables automatic
LaTeX-package installation. It will not update or modify the existing LaTeX
installation. Install any reported missing package with that distribution's
normal package manager.

### Option B: install Quarto-managed TinyTeX

If `lualatex --version` does not work or you do not maintain a LaTeX
installation, run this VS Code task once:

```text
ISyE 524: Install Quarto-managed TinyTeX (optional)
```

Confirm the installation in a VS Code terminal with:

```text
quarto list tools
```

Quarto installs this TinyTeX for the user account, not inside the repository,
and the task does not add it to the system `PATH`. It therefore does not replace
or take over an existing system LaTeX installation. When exporting, use:

```text
ISyE 524: Export active notebook to PDF (TinyTeX)
```

In WSL, TinyTeX is installed inside the Linux distribution (normally under
`~/.TinyTeX`), separately from any LaTeX installation on Windows. This is the
expected arrangement.

See [Exporting a notebook to PDF](pdf-export.md) for the assignment export
workflow and troubleshooting.

## 10. Final notebook check

Open `notebooks/00-check-installation.ipynb`. If prompted for a kernel, choose
Julia 1.12, then select **Run All**. Confirm that the optimization result,
table, plot, and Markdown mathematics all appear.

Then follow [Assignments and PDF Submission](canvas-assignment-workflow.md) to
create the Homework 0 working copy and submit its PDF.
