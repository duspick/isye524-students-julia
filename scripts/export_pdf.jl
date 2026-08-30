const REPOSITORY_ROOT = dirname(abspath(@__DIR__))
const SUBMISSIONS_DIR = joinpath(REPOSITORY_ROOT, "submissions")

function usage_error(message)
    error(
        message * "\n\n" *
        "Run this task while an .ipynb file inside the course repository is active.",
    )
end

function parse_arguments(arguments)
    use_system_tex = false
    notebook_arguments = String[]

    for argument in arguments
        if argument == "--system-tex"
            use_system_tex = true
        elseif startswith(argument, "--")
            usage_error("Unknown option: $(argument)")
        else
            push!(notebook_arguments, argument)
        end
    end

    length(notebook_arguments) == 1 || usage_error("Expected one notebook path.")
    return abspath(only(notebook_arguments)), use_system_tex
end

function is_inside_repository(path)
    try
        relative_path = relpath(realpath(path), realpath(REPOSITORY_ROOT))
        parts = splitpath(relative_path)
        return isempty(parts) || first(parts) != ".."
    catch
        return false
    end
end

function find_quarto()
    quarto = Sys.which("quarto")
    if isnothing(quarto)
        error(
            "Quarto was not found. Install Quarto, restart VS Code, and run " *
            "the 'ISyE 524: Check PDF export tools' task.",
        )
    end
    return quarto
end

function tinytex_install_directories()
    if Sys.islinux()
        return [joinpath(homedir(), ".TinyTeX")]
    elseif Sys.isapple()
        return [joinpath(homedir(), "Library", "TinyTeX")]
    elseif Sys.iswindows()
        locations = String[]
        for variable in ("APPDATA", "ProgramData")
            haskey(ENV, variable) && push!(locations, joinpath(ENV[variable], "TinyTeX"))
        end
        return locations
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

function require_quarto_tinytex()
    any(contains_lualatex, tinytex_install_directories()) && return

    error(
        "Quarto-managed TinyTeX is not installed. Run the " *
        "'ISyE 524: Install Quarto-managed TinyTeX (optional)' task, or " *
        "use the system-TeX export task if you maintain your own TeX installation.",
    )
end

function quarto_arguments(quarto, notebook, output_name, use_system_tex)
    arguments = String[
        quarto,
        "render",
        notebook,
        "--to",
        "pdf",
        "--output",
        output_name,
        "--output-dir",
        SUBMISSIONS_DIR,
        "--metadata",
        "monofont:TeX Gyre Cursor",
        "--no-execute",
    ]

    if use_system_tex
        append!(arguments, [
            "--metadata",
            "latex-tinytex:false",
            "--metadata",
            "latex-auto-install:false",
        ])
    end
    return arguments
end

function main(arguments)
    notebook, use_system_tex = parse_arguments(arguments)

    isfile(notebook) || usage_error("Notebook does not exist: $(notebook)")
    endswith(lowercase(notebook), ".ipynb") || usage_error("Not an .ipynb notebook: $(notebook)")
    is_inside_repository(notebook) || usage_error("Notebook is outside the course repository: $(notebook)")

    quarto = find_quarto()
    if !use_system_tex
        require_quarto_tinytex()
    end

    mkpath(SUBMISSIONS_DIR)
    output_name = replace(basename(notebook), r"\.ipynb$"i => ".pdf")
    arguments = quarto_arguments(quarto, notebook, output_name, use_system_tex)

    tex_description = if use_system_tex
        "system TeX (automatic package installation disabled)"
    else
        "Quarto-managed TinyTeX"
    end
    println("Rendering saved notebook content with $(tex_description)...")
    command = Cmd(Cmd(arguments); dir = REPOSITORY_ROOT)
    run(command)

    println()
    println("PDF ready: ", joinpath(SUBMISSIONS_DIR, output_name))
    println("Open the PDF and check every page before uploading it to Gradescope.")
end

if abspath(PROGRAM_FILE) == @__FILE__
    main(ARGS)
end
