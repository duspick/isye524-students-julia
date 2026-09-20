const REPOSITORY_ROOT = dirname(abspath(@__DIR__))
const UPDATE_HELP_URL =
    "https://github.com/jlinderoth/isye524-students-julia/blob/main/docs/course-updates.md"

function git_command(git::String, arguments::String...)
    command = Cmd(String[git, arguments...])
    return Cmd(command; dir = REPOSITORY_ROOT)
end

function check_repository(git::String)
    actual_root = strip(
        read(git_command(git, "rev-parse", "--show-toplevel"), String),
    )
    if normpath(actual_root) != REPOSITORY_ROOT
        error(
            "The update task was not started from the ISyE 524 repository. " *
            "Expected $(REPOSITORY_ROOT), but Git reported $(actual_root).",
        )
    end

    tracked_changes = read(
        git_command(git, "status", "--porcelain", "--untracked-files=no"),
        String,
    )
    if !isempty(strip(tracked_changes))
        println("Local modifications were found:")
        for line in split(chomp(tracked_changes), '\n')
            println("  ", line)
        end
        println()
        println(
            "Git will preserve these edits. The pull can continue when the " *
            "course update changes other files, but Git will stop if an " *
            "incoming change overlaps your work.",
        )
        println()
    end
    return tracked_changes
end

function check_upstream(git::String)
    command = git_command(
        git,
        "rev-parse",
        "--abbrev-ref",
        "--symbolic-full-name",
        "@{upstream}",
    )
    if !success(pipeline(command; stdout = devnull, stderr = devnull))
        error(
            "The current Git branch has no upstream branch. Clone the course " *
            "repository from GitHub, or configure its upstream before using " *
            "this task.",
        )
    end
end

function main()
    git = Sys.which("git")
    isnothing(git) && error("Git was not found on PATH.")

    tracked_changes = check_repository(git)
    check_upstream(git)

    println("Updating ISyE 524 course files with a fast-forward-only pull...")
    try
        run(git_command(git, "pull", "--ff-only", "--no-autostash"))
    catch
        println(stderr)
        println(
            stderr,
            "Git could not apply the course update. Your local files were " *
            "not reset or automatically stashed. Read Git's message above; " *
            "if an updated course file overlaps your work, save a separate " *
            "copy before resolving the update.",
        )
        if occursin(".vscode/settings.json", tracked_changes)
            println(stderr)
            println(stderr, "Your local .vscode/settings.json has changes.")
            println(
                stderr,
                "If Git lists it as blocking the update, follow the one-time " *
                "settings migration in the guide below. Back up the file " *
                "before restoring it, then put your settings back after the update.",
            )
        end
        println(stderr)
        println(
            stderr,
            "For local edits or saved notebook outputs, run 'ISyE 524: Reset " *
            "course files to latest (with backup)' to save copies and replace " *
            "tracked files with the published versions.",
        )
        println(stderr, "Step-by-step update help: ", UPDATE_HELP_URL)
        println(stderr, "If you need help, send course staff the full task output.")
        exit(3)
    end
    println("Course files are up to date.")
end

main()
