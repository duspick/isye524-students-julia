function running_in_wsl()
    Sys.islinux() || return false

    release_file = "/proc/sys/kernel/osrelease"
    isfile(release_file) || return false
    return occursin("microsoft", lowercase(read(release_file, String)))
end

function installation_hint()
    if running_in_wsl()
        return """
        Quarto was not found inside WSL.

        A Quarto installation on Windows is not visible to tasks running in a
        VS Code WSL window. Install the Ubuntu/Debian .deb package inside WSL:

          1. Download the current .deb from https://quarto.org/docs/download/
          2. In the WSL terminal, change to the directory containing the download.
             Windows Downloads is normally /mnt/c/Users/<Windows-user>/Downloads.
          3. Run: sudo apt install ./quarto-<version>-linux-amd64.deb
          4. Run: quarto --version
          5. Reopen this repository from WSL with: code .

        Replace <Windows-user> and <version> with the names on your computer.
        """
    elseif Sys.islinux()
        return """
        Quarto was not found on this Linux system.

        On Ubuntu or Debian, download the current .deb from
        https://quarto.org/docs/download/, change to the download directory,
        and run:

            sudo apt install ./quarto-<version>-linux-amd64.deb

        Other Linux distributions can use Quarto's user-local tarball method:
        https://quarto.org/docs/download/tarball.html

        After installation, run quarto --version and restart VS Code.
        """
    elseif Sys.iswindows()
        return """
        Quarto was not found on Windows. Install the current Windows .msi from
        https://quarto.org/docs/download/, completely quit VS Code, reopen the
        repository, and run this task again.
        """
    elseif Sys.isapple()
        return """
        Quarto was not found on macOS. Install the current macOS .pkg from
        https://quarto.org/docs/download/, completely quit VS Code, reopen the
        repository, and run this task again.
        """
    else
        return "Install Quarto from https://quarto.org/docs/download/ and run this task again."
    end
end

function tinytex_install_directories()
    if Sys.islinux()
        return [joinpath(homedir(), ".TinyTeX")]
    elseif Sys.isapple()
        return [joinpath(homedir(), "Library", "TinyTeX")]
    elseif Sys.iswindows()
        directories = String[]
        for variable in ("APPDATA", "ProgramData")
            haskey(ENV, variable) && push!(directories, joinpath(ENV[variable], "TinyTeX"))
        end
        return directories
    else
        return String[]
    end
end

function contains_lualatex(directory)
    bin_directory = joinpath(directory, "bin")
    isdir(bin_directory) || return false

    for (_, _, files) in walkdir(bin_directory)
        any(file -> lowercase(file) in ("lualatex", "lualatex.exe"), files) && return true
    end
    return false
end

function main()
    quarto = Sys.which("quarto")
    if isnothing(quarto)
        println(stderr, installation_hint())
        return 1
    end

    println("Quarto executable: ", quarto)
    print("Quarto version: ")
    flush(stdout)
    run(`$quarto --version`)
    println()
    println("Running Quarto's installation check...")
    flush(stdout)
    run(`$quarto check install`)

    println()
    lualatex = Sys.which("lualatex")
    tinytex = findfirst(contains_lualatex, tinytex_install_directories())
    if !isnothing(lualatex)
        println("System lualatex: ", lualatex)
        println("You may use the system-TeX PDF export task.")
    elseif !isnothing(tinytex)
        directory = tinytex_install_directories()[tinytex]
        println("Quarto-managed TinyTeX: ", directory)
        println("Use the TinyTeX PDF export task.")
    else
        println("System lualatex: not found")
        println(
            "Next step: run 'ISyE 524: Install Quarto-managed TinyTeX " *
            "(optional)' unless you plan to install and maintain system TeX.",
        )
    end

    return 0
end

abspath(PROGRAM_FILE) == abspath(@__FILE__) && exit(main())
