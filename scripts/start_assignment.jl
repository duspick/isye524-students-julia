const REPOSITORY_ROOT = dirname(abspath(@__DIR__))
const ASSIGNMENT_ID_PATTERN = r"^[A-Za-z0-9][A-Za-z0-9_-]*$"

function available_assignments(repository_root)
    assignments_directory = joinpath(repository_root, "assignments")
    isdir(assignments_directory) || return String[]

    names = filter(readdir(assignments_directory)) do name
        isdir(joinpath(assignments_directory, name)) &&
            occursin(ASSIGNMENT_ID_PATTERN, name)
    end
    return sort(names)
end

function start_assignment(repository_root, requested_id)
    assignment_id = strip(requested_id)
    if !occursin(ASSIGNMENT_ID_PATTERN, assignment_id)
        error(
            "Invalid assignment name '$(assignment_id)'. Use the name supplied " *
            "by the instructor, such as hw01. Letters, numbers, underscores, " *
            "and hyphens are allowed.",
        )
    end

    source = joinpath(repository_root, "assignments", assignment_id)
    if !isdir(source)
        available = available_assignments(repository_root)
        detail = if isempty(available)
            "No assignment templates are currently available."
        else
            "Available assignments: " * join(available, ", ")
        end
        error("Assignment template '$(assignment_id)' was not found. $(detail)")
    end

    work_root = joinpath(repository_root, "student-work")
    destination = joinpath(work_root, assignment_id)
    mkpath(work_root)

    if ispath(destination)
        error(
            "Student work already exists at $(destination). Nothing was " *
            "overwritten. Open that folder to continue your assignment.",
        )
    end

    cp(source, destination; force = false, follow_symlinks = false)

    notebooks = String[]
    for (directory, _, files) in walkdir(destination)
        for file in files
            endswith(lowercase(file), ".ipynb") &&
                push!(notebooks, joinpath(directory, file))
        end
    end

    println("Assignment workspace created: ", destination)
    if isempty(notebooks)
        println("No notebook was included; follow the assignment instructions in that folder.")
    else
        println("Open this notebook in VS Code:")
        for notebook in sort(notebooks)
            println("  ", notebook)
        end
    end
    println("Keep a separate backup: student-work is intentionally not tracked by Git.")

    return destination
end

function main(arguments)
    length(arguments) == 1 || error(
        "Expected one assignment name, for example: " *
        "julia --project=. scripts/start_assignment.jl hw01",
    )
    start_assignment(REPOSITORY_ROOT, only(arguments))
end

abspath(PROGRAM_FILE) == abspath(@__FILE__) && main(ARGS)
