using JSON

const REPOSITORY_ROOT = dirname(abspath(@__DIR__))
const SKIPPED_NOTEBOOK_DIRECTORIES = Set([
    ".git",
    ".ipynb_checkpoints",
    ".jupyter_cache",
    ".quarto",
    ".venv",
    "student-work",
    "submissions",
    "tmp",
    "venv",
])

function notebook_issues(notebook)
    issues = String[]
    cells = get(notebook, "cells", nothing)
    if !(cells isa AbstractVector)
        push!(issues, "missing or invalid cells array")
        return issues
    end

    for (index, cell) in enumerate(cells)
        cell isa AbstractDict || continue
        get(cell, "cell_type", nothing) == "code" || continue

        outputs = get(cell, "outputs", nothing)
        if !(outputs isa AbstractVector) || !isempty(outputs)
            push!(issues, "code cell $(index) has saved outputs")
        end

        if !haskey(cell, "execution_count") || !isnothing(cell["execution_count"])
            push!(issues, "code cell $(index) has an execution count")
        end

        metadata = get(cell, "metadata", nothing)
        if metadata isa AbstractDict && haskey(metadata, "execution")
            push!(issues, "code cell $(index) has execution metadata")
        end
    end

    metadata = get(notebook, "metadata", nothing)
    if metadata isa AbstractDict && haskey(metadata, "widgets")
        push!(issues, "notebook metadata contains saved widget state")
    end

    return issues
end

function clean_notebook_data!(notebook)
    cells = get(notebook, "cells", nothing)
    cells isa AbstractVector || error("Notebook is missing a valid cells array.")

    for cell in cells
        cell isa AbstractDict || continue
        get(cell, "cell_type", nothing) == "code" || continue

        cell["outputs"] = Any[]
        cell["execution_count"] = nothing

        metadata = get(cell, "metadata", nothing)
        metadata isa AbstractDict && delete!(metadata, "execution")
    end

    metadata = get(notebook, "metadata", nothing)
    metadata isa AbstractDict && delete!(metadata, "widgets")
    return notebook
end

function read_notebook(path)
    try
        return JSON.parsefile(path)
    catch exception
        error("Could not parse notebook $(path): $(sprint(showerror, exception))")
    end
end

function clean_notebook(path)
    notebook = read_notebook(path)
    issues = notebook_issues(notebook)
    isempty(issues) && return false

    clean_notebook_data!(notebook)
    open(path, "w") do io
        JSON.print(io, notebook, 1)
        write(io, '\n')
    end
    return true
end

function discover_notebooks(directory)
    notebooks = String[]
    for (root, directories, files) in walkdir(directory)
        filter!(name -> !(name in SKIPPED_NOTEBOOK_DIRECTORIES), directories)
        for file in files
            endswith(lowercase(file), ".ipynb") &&
                push!(notebooks, abspath(joinpath(root, file)))
        end
    end
    return sort(notebooks)
end

function resolve_notebooks(arguments)
    isempty(arguments) && return discover_notebooks(REPOSITORY_ROOT)

    notebooks = String[]
    for argument in arguments
        path = abspath(argument)
        if isdir(path)
            append!(notebooks, discover_notebooks(path))
        elseif isfile(path) && endswith(lowercase(path), ".ipynb")
            push!(notebooks, path)
        else
            error("Notebook path does not exist or is not an .ipynb file: $(argument)")
        end
    end
    return sort(unique(notebooks))
end

function check_notebooks(paths)
    dirty = false
    for path in paths
        issues = notebook_issues(read_notebook(path))
        isempty(issues) && continue

        dirty = true
        println(stderr, relpath(path, REPOSITORY_ROOT), ":")
        for issue in issues
            println(stderr, "  - ", issue)
        end
    end
    return !dirty
end

function clean_notebooks(paths)
    cleaned = String[]
    for path in paths
        clean_notebook(path) && push!(cleaned, path)
    end
    return cleaned
end

function main(arguments)
    isempty(arguments) && error("Expected --check or --clean.")
    mode = first(arguments)
    mode in ("--check", "--clean") || error("Expected --check or --clean, got $(mode).")
    paths = resolve_notebooks(arguments[2:end])

    if mode == "--check"
        if check_notebooks(paths)
            println("Notebook hygiene check passed ($(length(paths)) notebook(s)).")
        else
            println(stderr, "Run the maintainer notebook-cleaning task, then stage the cleaned files.")
            exit(1)
        end
    else
        cleaned = clean_notebooks(paths)
        if isempty(cleaned)
            println("Notebook outputs are already clean ($(length(paths)) notebook(s)).")
        else
            println("Cleaned notebook outputs:")
            foreach(path -> println("  ", relpath(path, REPOSITORY_ROOT)), cleaned)
        end
    end
end

abspath(PROGRAM_FILE) == abspath(@__FILE__) && main(ARGS)
