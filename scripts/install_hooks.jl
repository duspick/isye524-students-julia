function main()
    git = Sys.which("git")
    isnothing(git) && error("Git was not found on PATH.")

    repository_root = readchomp(Cmd([git, "rev-parse", "--show-toplevel"]))
    config_command = Cmd(Cmd([git, "config", "--local", "core.hooksPath", ".githooks"]); dir = repository_root)
    run(config_command)

    read_command = Cmd(Cmd([git, "config", "--local", "--get", "core.hooksPath"]); dir = repository_root)
    configured_path = readchomp(read_command)
    configured_path == ".githooks" || error("Git hook configuration was not saved.")

    println("Maintainer Git hooks enabled for: ", repository_root)
    println("Staged notebooks will be cleaned automatically before each commit.")
end

main()
