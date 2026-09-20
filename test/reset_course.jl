using Test

module CourseReset
include(joinpath(@__DIR__, "..", "scripts", "reset_course.jl"))
end

function reset_git(repository, arguments...)
    command = Cmd(Cmd(String["git", arguments...]); dir = repository)
    return strip(read(pipeline(command; stderr = devnull), String))
end

function reset_write(repository, name, content)
    path = joinpath(repository, name)
    mkpath(dirname(path))
    write(path, content)
end

function reset_fixture(callback)
    mktempdir() do directory
        config = joinpath(directory, "empty-gitconfig")
        write(config, "")
        withenv("GIT_CONFIG_GLOBAL" => config, "GIT_CONFIG_NOSYSTEM" => "1", "GIT_TERMINAL_PROMPT" => "0") do
            publisher = joinpath(directory, "publisher")
            repository = joinpath(directory, "student clone")
            mkdir(publisher)
            reset_git(publisher, "init", "--initial-branch=main")
            reset_git(publisher, "config", "user.name", "Course Test")
            reset_git(publisher, "config", "user.email", "test@example.invalid")
            reset_write(publisher, "notebooks/example.ipynb", "original notebook\n")
            reset_write(publisher, ".vscode/settings.json", "{\"editor.fontSize\": 14}\n")
            reset_write(publisher, "scripts/setup.jl", "write(joinpath(@__DIR__, \"..\", \"setup-ran\"), \"ready\")\n")
            reset_write(publisher, ".gitignore", "/student-work/\n/submissions/\n*.bin\n")
            reset_write(publisher, "remove-me.txt", "original\n")
            reset_git(publisher, "add", ".")
            reset_git(publisher, "commit", "-m", "Original course")
            reset_git(directory, "clone", publisher, repository)
            reset_git(repository, "config", "user.name", "Student Test")
            reset_git(repository, "config", "user.email", "student@example.invalid")
            reset_git(publisher, "rm", ".vscode/settings.json")
            reset_write(publisher, ".gitignore", "/student-work/\n/submissions/\n/.vscode/settings.json\n*.bin\n")
            reset_write(publisher, "notebooks/example.ipynb", "corrected course notebook\n")
            reset_git(publisher, "add", ".")
            reset_git(publisher, "commit", "-m", "Latest course and settings migration")
            callback(directory, publisher, repository)
        end
    end
end

quiet_reset(repository, publisher) = redirect_stdout(devnull) do
    redirect_stderr(devnull) do
        CourseReset.reset_course(repository; allowed_remote_urls = (publisher,))
    end
end

@testset "Course reset preserves work and history" begin
    reset_fixture() do directory, publisher, repository
        reset_write(repository, "committed-note.txt", "personal committed notes\n")
        reset_git(repository, "add", "committed-note.txt")
        reset_git(repository, "commit", "-m", "Local student commit")
        local_head = reset_git(repository, "rev-parse", "HEAD")
        reset_write(repository, "notebooks/example.ipynb", "staged notebook notes\n")
        reset_git(repository, "add", "notebooks/example.ipynb")
        saved_notebook = "{\"cells\":[{\"cell_type\":\"code\",\"source\":[\"println(42)\"],\"execution_count\":1,\"outputs\":[{\"output_type\":\"stream\",\"name\":\"stdout\",\"text\":[\"42\\n\"]}]}]}\n"
        reset_write(repository, "notebooks/example.ipynb", saved_notebook)
        reset_write(repository, ".vscode/settings.json", "{\"editor.fontSize\": 22}\n")
        reset_write(repository, "student-work/hw01/answer.ipynb", "homework answers\n")
        reset_write(repository, "submissions/hw01.pdf", "submitted PDF\n")
        reset_write(repository, "keep-me.txt", "untracked personal file\n")
        rm(joinpath(repository, "remove-me.txt"))

        # Cover both ignored and untracked incoming collisions, including
        # changes between a file and a directory, which reset --hard can delete.
        for (path, personal, published) in (
            ("notebooks/new.ipynb", "personal new notebook\n", "new course notebook\n"),
            ("data/new.bin", "personal ignored data\n", "published data\n"),
        )
            reset_write(repository, path, personal)
            reset_write(publisher, path, published)
        end
        reset_write(repository, "scratch/notes.txt", "personal directory contents\n")
        reset_write(publisher, "scratch", "published file\n")
        reset_write(repository, "extras", "personal file\n")
        reset_write(publisher, "extras/new.txt", "published child\n")
        reset_git(publisher, "add", "-f", ".")
        reset_git(publisher, "commit", "-m", "New course files")

        backup = quiet_reset(repository, publisher)
        # macOS temporary paths can use /var, which resolves to /private/var.
        @test realpath(dirname(backup)) == realpath(directory)
        @test startswith(basename(backup), "student clone-backup-")
        @test reset_git(repository, "rev-parse", "HEAD") == reset_git(publisher, "rev-parse", "HEAD")
        @test read(joinpath(repository, "notebooks/example.ipynb"), String) == "corrected course notebook\n"
        @test read(joinpath(backup, "working-tree/notebooks/example.ipynb"), String) == saved_notebook
        @test occursin("staged notebook notes", read(joinpath(backup, "staged.patch"), String))
        @test occursin("staged notebook notes", read(joinpath(backup, "unstaged.patch"), String))
        @test occursin("remove-me.txt", read(joinpath(backup, "status.txt"), String))
        @test read(joinpath(repository, "student-work/hw01/answer.ipynb"), String) == "homework answers\n"
        @test read(joinpath(repository, "submissions/hw01.pdf"), String) == "submitted PDF\n"
        @test read(joinpath(repository, ".vscode/settings.json"), String) == "{\"editor.fontSize\": 22}\n"
        @test reset_git(repository, "check-ignore", ".vscode/settings.json") == ".vscode/settings.json"
        @test read(joinpath(repository, "keep-me.txt"), String) == "untracked personal file\n"
        @test read(joinpath(backup, "working-tree/notebooks/new.ipynb"), String) == "personal new notebook\n"
        @test read(joinpath(backup, "working-tree/data/new.bin"), String) == "personal ignored data\n"
        @test read(joinpath(backup, "working-tree/scratch/notes.txt"), String) == "personal directory contents\n"
        @test read(joinpath(backup, "working-tree/extras"), String) == "personal file\n"
        @test read(joinpath(repository, "notebooks/new.ipynb"), String) == "new course notebook\n"
        @test read(joinpath(repository, "data/new.bin"), String) == "published data\n"
        @test read(joinpath(repository, "scratch"), String) == "published file\n"
        @test read(joinpath(repository, "extras/new.txt"), String) == "published child\n"

        recovered = joinpath(directory, "recovered")
        reset_git(directory, "clone", joinpath(backup, "repository.bundle"), recovered)
        @test reset_git(recovered, "rev-parse", "HEAD") == local_head
        @test read(joinpath(recovered, "committed-note.txt"), String) == "personal committed notes\n"
        @test !ispath(joinpath(repository, "committed-note.txt"))
        another_backup = quiet_reset(repository, publisher)
        @test another_backup != backup
        @test isfile(joinpath(backup, "repository.bundle"))
    end
end

@testset "Course reset stops before replacing protected files" begin
    for path in ("student-work/answers.txt", "submissions/report.pdf", ".vscode/settings.json", "student-work", ".vscode")
        reset_fixture() do directory, publisher, repository
            reset_write(publisher, path, "must not overwrite personal files\n")
            reset_git(publisher, "add", "-f", path)
            reset_git(publisher, "commit", "-m", "Accidentally track a protected path")
            original = reset_git(repository, "rev-parse", "HEAD")
            reset_write(repository, "student-work/answers.txt", "personal answers\n")
            @test_throws ErrorException quiet_reset(repository, publisher)
            @test reset_git(repository, "rev-parse", "HEAD") == original
            @test read(joinpath(repository, "student-work/answers.txt"), String) == "personal answers\n"
            @test !any(name -> occursin("-backup-", name), readdir(directory))
        end
    end
    reset_fixture() do directory, publisher, repository
        reset_write(repository, "student-work/answers.txt", "accidentally staged answers\n")
        reset_git(repository, "add", "-f", "student-work/answers.txt")
        original = reset_git(repository, "rev-parse", "HEAD")
        @test_throws ErrorException quiet_reset(repository, publisher)
        @test reset_git(repository, "rev-parse", "HEAD") == original
        @test read(joinpath(repository, "student-work/answers.txt"), String) == "accidentally staged answers\n"
    end
end

@testset "Course reset validates its source and stops on fetch failure" begin
    reset_fixture() do directory, publisher, repository
        original = reset_git(repository, "rev-parse", "HEAD")
        @test_throws ErrorException CourseReset.reset_course(repository)
        @test reset_git(repository, "rev-parse", "HEAD") == original
        missing = joinpath(directory, "missing remote")
        reset_git(repository, "remote", "set-url", "origin", missing)
        @test_throws ProcessFailedException quiet_reset(repository, missing)
        @test reset_git(repository, "rev-parse", "HEAD") == original
        @test !any(name -> occursin("-backup-", name), readdir(directory))
    end
end

@testset "Reset task cancellation and environment refresh" begin
    reset_fixture() do directory, publisher, repository
        original = reset_git(repository, "rev-parse", "HEAD")
        CourseReset.main(["Cancel"]; repository = repository)
        @test reset_git(repository, "rev-parse", "HEAD") == original
        @test !ispath(joinpath(repository, "setup-ran"))
        redirect_stdout(devnull) do
            redirect_stderr(devnull) do
                CourseReset.main(["RESET"]; repository = repository, allowed_remote_urls = (publisher,))
            end
        end
        @test read(joinpath(repository, "setup-ran"), String) == "ready"
        @test reset_git(repository, "rev-parse", "HEAD") == reset_git(publisher, "rev-parse", "HEAD")
    end
    reset_fixture() do directory, publisher, repository
        reset_write(publisher, "scripts/setup.jl", "error(\"Simulated package installation failure\")\n")
        reset_git(publisher, "add", "scripts/setup.jl")
        reset_git(publisher, "commit", "-m", "Setup that fails")
        redirect_stdout(devnull) do
            redirect_stderr(devnull) do
                @test_throws ProcessFailedException CourseReset.main(
                    ["RESET"]; repository = repository, allowed_remote_urls = (publisher,),
                )
            end
        end
        @test reset_git(repository, "rev-parse", "HEAD") == reset_git(publisher, "rev-parse", "HEAD")
        backups = filter(name -> occursin("-backup-", name), readdir(directory))
        @test length(backups) == 1
        @test isfile(joinpath(directory, only(backups), "repository.bundle"))
    end
end

# Windows permissions differ; this verifies the failure path on Unix runners
# where the test account cannot bypass directory write permissions.
if Sys.isunix() && ccall(:geteuid, Cuint, ()) != 0
    @testset "Backup failure leaves the checkout untouched" begin
        reset_fixture() do directory, publisher, repository
            original = reset_git(repository, "rev-parse", "HEAD")
            reset_write(repository, "notebooks/example.ipynb", "irreplaceable saved work\n")
            chmod(directory, 0o500)
            try
                @test_throws Base.IOError quiet_reset(repository, publisher)
                @test reset_git(repository, "rev-parse", "HEAD") == original
                @test read(joinpath(repository, "notebooks/example.ipynb"), String) == "irreplaceable saved work\n"
            finally
                chmod(directory, 0o700)
            end
        end
    end
end
