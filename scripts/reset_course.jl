using Dates

const REPOSITORY_ROOT = dirname(abspath(@__DIR__))
const COURSE_REMOTE_URLS = (
    "https://github.com/jlinderoth/isye524-students-julia.git",
    "https://github.com/jlinderoth/isye524-students-julia",
    "git@github.com:jlinderoth/isye524-students-julia.git",
    "ssh://git@github.com/jlinderoth/isye524-students-julia.git",
)
const PERSONAL_DIRECTORIES = ("student-work", "submissions")
const SETTINGS_PATH = ".vscode/settings.json"
const COURSE_UPSTREAM = "refs/remotes/origin/main"

git_command(git, repository, arguments...) =
    Cmd(Cmd(String[git, arguments...]); dir = repository)
git_read(git, repository, arguments...) =
    read(git_command(git, repository, arguments...), String)
git_value(git, repository, arguments...) =
    strip(git_read(git, repository, arguments...))
git_paths(git, repository, arguments...) =
    String.(split(git_read(git, repository, arguments...), '\0'; keepempty = false))

# Check both directions: an incoming file named "student-work" would replace
# the whole directory just as surely as an incoming "student-work/hw01.ipynb".
paths_overlap(first, second) = first == second ||
    startswith(first, second * "/") || startswith(second, first * "/")

function check_checkout(git, repository, allowed_remote_urls)
    actual_root = git_value(git, repository, "rev-parse", "--show-toplevel")
    realpath(actual_root) == realpath(repository) || error("Open the course repository root.")
    branch = git_value(git, repository, "symbolic-ref", "--short", "HEAD")
    upstream = git_value(git, repository, "rev-parse", "--symbolic-full-name", "@{upstream}")
    upstream == COURSE_UPSTREAM || error(
        "Reset requires a branch tracking origin/main. Ask course staff for help.",
    )
    remote = git_value(git, repository, "remote", "get-url", "origin")
    remote in allowed_remote_urls || error(
        "origin is not the official ISyE 524 course repository. Nothing was reset.",
    )
    git_value(git, repository, "rev-parse", "--is-shallow-repository") == "true" &&
        error("Reset needs a full clone to back up Git history. Ask course staff for help.")
    isempty(git_read(git, repository, "ls-files", "--unmerged")) ||
        error("There are unresolved Git conflicts. Ask course staff for help first.")
    for marker in ("MERGE_HEAD", "CHERRY_PICK_HEAD", "REVERT_HEAD", "rebase-merge", "rebase-apply", "sequencer")
        path = git_value(git, repository, "rev-parse", "--git-path", marker)
        ispath(joinpath(repository, path)) && error(
            "A Git operation is in progress ($(marker)). Ask course staff for help first.",
        )
    end
    sparse = git_command(git, repository, "config", "--bool", "core.sparseCheckout")
    if success(pipeline(sparse; stdout = devnull, stderr = devnull)) &&
       strip(read(sparse, String)) == "true"
        error("Reset does not support sparse checkouts. Ask course staff for help.")
    end
    return branch
end

function check_paths(git, repository, target)
    head_paths = git_paths(git, repository, "ls-tree", "-r", "--name-only", "-z", "HEAD")
    index_paths = git_paths(git, repository, "ls-files", "-z")
    target_paths = git_paths(git, repository, "ls-tree", "-r", "--name-only", "-z", target)

    for path in union(head_paths, index_paths), protected in PERSONAL_DIRECTORIES
        paths_overlap(lowercase(path), protected) && error(
            "Git is tracking personal files under $(protected). Nothing was reset; ask course staff for help.",
        )
    end
    for path in target_paths, protected in (PERSONAL_DIRECTORIES..., SETTINGS_PATH)
        paths_overlap(lowercase(path), protected) && error(
            "The published course version would overwrite $(protected). Nothing was reset; ask course staff for help.",
        )
    end
    "scripts/setup.jl" in target_paths || error("The published version is missing scripts/setup.jl.")
    for revision in ("HEAD", target)
        entries = git_paths(git, repository, "ls-tree", "-r", "-z", revision)
        any(entry -> startswith(entry, "160000 "), entries) &&
            error("Reset does not support repositories with submodules.")
    end
    entries = git_paths(git, repository, "ls-files", "--stage", "-z")
    any(entry -> startswith(entry, "160000 "), entries) &&
        error("Reset does not support staged submodules.")
    # Avoid following a workspace-directory symlink when preserving settings.
    islink(joinpath(repository, ".vscode")) && error("The .vscode directory must not be a symbolic link.")
    settings = joinpath(repository, SETTINGS_PATH)
    isdir(settings) && !islink(settings) && error("Expected a settings file, not a settings.json directory.")
    return union(head_paths, index_paths, target_paths, [SETTINGS_PATH])
end

# Save all currently tracked files, plus any local files/directories that
# incoming paths would overwrite. Other untracked and ignored files stay put.
# A symlink or file in an ancestor position must be copied itself, not followed.
function backup_paths(repository, candidates)
    roots = Set{String}()
    for path in candidates
        parts = split(path, '/')
        for count in eachindex(parts)
            relative = join(parts[1:count], '/')
            source = joinpath(repository, relative)
            if islink(source) || isfile(source) || (count == length(parts) && isdir(source))
                push!(roots, relative)
                break
            end
        end
    end
    return sort(filter(collect(roots)) do path
        !any(parent -> parent != path && startswith(path, parent * "/"), roots)
    end)
end

function create_backup(git, repository, branch, target, candidates)
    prefix = basename(repository) * "-backup-" * Dates.format(now(), "yyyymmdd-HHMMSS") * "-"
    backup = mktempdir(dirname(repository); prefix = prefix, cleanup = false)
    println("Creating backup: ", backup)
    # An independent Git bundle preserves local commits even after the current
    # branch moves. Patches separately retain staged and unstaged versions.
    run(git_command(git, repository, "bundle", "create", joinpath(backup, "repository.bundle"), "--all"))
    run(pipeline(git_command(git, repository, "bundle", "verify", joinpath(backup, "repository.bundle"));
        stdout = devnull, stderr = devnull))
    for (name, arguments) in (
        ("staged.patch", ["diff", "--cached", "--binary", "--full-index", "--no-ext-diff", "--no-textconv", "HEAD"]),
        ("unstaged.patch", ["diff", "--binary", "--full-index", "--no-ext-diff", "--no-textconv"]),
        ("status.txt", ["status", "--short", "--untracked-files=all"]),
    )
        open(joinpath(backup, name), "w") do io
            run(pipeline(git_command(git, repository, arguments...); stdout = io))
        end
    end
    for path in backup_paths(repository, candidates)
        destination = joinpath(backup, "working-tree", path)
        mkpath(dirname(destination))
        cp(joinpath(repository, path), destination; follow_symlinks = false)
    end
    original_head = git_value(git, repository, "rev-parse", "HEAD")
    write(joinpath(backup, "README.txt"), """
    ISyE 524 course reset backup
    Repository: $(repository)
    Branch: $(branch)
    Original commit: $(original_head)
    Course commit: $(target)

    working-tree/ contains saved copies of tracked files and local files that
    the update could overwrite, including notebook code, notes, and outputs.
    Open these copies to recover work. Copy personal notebooks into student-work/
    in the course repository; include any data or images they need.
    Missing/deleted files are recorded in status.txt and the patches.

    staged.patch and unstaged.patch preserve the two sets of uncommitted changes.
    repository.bundle preserves Git history, including local commits and stashes.
    Ask course staff for help recovering staged changes or Git history. Do not
    apply all backup changes to the refreshed repository automatically.

    Personal folders student-work/ and submissions/ are left in place. This is
    not a replacement for your regular backup of those folders. Unsaved editor
    changes cannot be included here.
    """)
    return backup
end

function reset_course(repository; git = Sys.which("git"), allowed_remote_urls = COURSE_REMOTE_URLS)
    isnothing(git) && error("Git was not found on PATH.")
    repository = realpath(repository)
    branch = check_checkout(git, repository, allowed_remote_urls)
    println("Downloading the latest published course files...")
    run(git_command(git, repository, "fetch", "--no-tags", "origin",
        "+refs/heads/main:refs/remotes/origin/main"))
    target = git_value(git, repository, "rev-parse", "--verify", COURSE_UPSTREAM * "^{commit}")
    candidates = check_paths(git, repository, target)
    backup = create_backup(git, repository, branch, target, candidates)
    println("Backup complete: ", backup)
    println("Replacing tracked course files with the published version...")
    try
        run(git_command(git, repository, "reset", "--hard", "--no-recurse-submodules", target))
    finally
        # Old clones may still track settings.json. Restore the saved personal
        # copy even when the reset removes that formerly tracked file.
        saved_settings = joinpath(backup, "working-tree", SETTINGS_PATH)
        if ispath(saved_settings) || islink(saved_settings)
            settings = joinpath(repository, SETTINGS_PATH)
            mkpath(dirname(settings))
            cp(saved_settings, settings; force = true, follow_symlinks = false)
        end
    end
    println("Course files reset successfully. Your backup is at: ", backup)
    return backup
end

function main(arguments; repository = REPOSITORY_ROOT, allowed_remote_urls = COURSE_REMOTE_URLS)
    if isempty(arguments) || arguments == ["Cancel"]
        println("Reset cancelled. Save and close notebooks before selecting RESET.")
        println("Terminal usage: julia --startup-file=no scripts/reset_course.jl RESET")
        return
    end
    arguments == ["RESET"] || error("Expected RESET or Cancel.")
    backup = reset_course(repository; allowed_remote_urls = allowed_remote_urls)
    println("Refreshing the Julia environment...")
    setup = joinpath(repository, "scripts", "setup.jl")
    try
        run(`$(Base.julia_cmd()) --startup-file=no --project=$repository $setup`)
    catch
        println(stderr, "Course files were reset, but environment setup failed.")
        println(stderr, "Rerun 'ISyE 524: Set up / refresh Julia environment'.")
        rethrow()
    finally
        println("Backup retained at: ", backup)
    end
end

if abspath(PROGRAM_FILE) == abspath(@__FILE__)
    try
        main(ARGS)
    catch exception
        println(stderr, "Course reset stopped: ", sprint(showerror, exception))
        exit(3)
    end
end
