include(joinpath(@__DIR__, "notebook_hygiene.jl"))

function git_output(git, arguments)
    return read(Cmd(vcat([git], arguments)), String)
end

function staged_notebooks(git)
    output = git_output(git, [
        "diff",
        "--cached",
        "--name-only",
        "--diff-filter=ACMR",
        "-z",
        "--",
        "*.ipynb",
    ])
    return filter(!isempty, split(output, '\0'))
end

function has_unstaged_changes(git, path)
    command = Cmd([git, "diff", "--quiet", "--", path])
    return !success(run(ignorestatus(command)))
end

function main()
    git = Sys.which("git")
    isnothing(git) && error("Git was not found on PATH.")

    repository_root = readchomp(Cmd([git, "rev-parse", "--show-toplevel"]))
    cd(repository_root) do
        notebooks = staged_notebooks(git)
        isempty(notebooks) && return

        partially_staged = filter(path -> has_unstaged_changes(git, path), notebooks)
        if !isempty(partially_staged)
            println(stderr, "Cannot safely clean partially staged notebooks:")
            foreach(path -> println(stderr, "  ", path), partially_staged)
            println(stderr, "Stage or discard their unstaged changes, then commit again.")
            exit(1)
        end

        absolute_paths = map(path -> joinpath(repository_root, path), notebooks)
        cleaned = clean_notebooks(absolute_paths)
        if !isempty(cleaned)
            run(Cmd(vcat([git, "add", "--"], notebooks)))
            println("Removed saved outputs from $(length(cleaned)) staged notebook(s).")
        end

        check_notebooks(absolute_paths) || exit(1)
    end
end

abspath(PROGRAM_FILE) == abspath(@__FILE__) && main()
