using JSON
using JuMP
# Notebook kernels load REPL, which enables formatted documentation from @doc.
using REPL
using Test
import MathOptInterface as MOI

const REPOSITORY_ROOT = dirname(@__DIR__)

module AssignmentWorkspace
include(joinpath(@__DIR__, "..", "scripts", "start_assignment.jl"))
end

function read_notebook(path)
    notebook = JSON.parsefile(path)
    @test notebook["nbformat"] == 4
    @test notebook["nbformat_minor"] == 5
    @test notebook["metadata"]["kernelspec"]["name"] == "julia-1.12"
    @test all(cell -> haskey(cell, "id"), notebook["cells"])
    return notebook
end

function execute_code_cells(module_, path; cell_filename = path)
    notebook = read_notebook(path)
    code = join(
        join(cell["source"])
        for cell in notebook["cells"]
        if get(cell, "cell_type", nothing) == "code"
    )
    @test !occursin(r"Pkg\.(add|update)\s*\(", code)
    for cell in notebook["cells"]
        get(cell, "cell_type", nothing) == "code" || continue
        Base.include_string(module_, join(cell["source"]), cell_filename)
    end
    return module_
end

module JuliaTutorial end
module HomeworkZero end

@testset "Homework 0 starter notebooks" begin
    tutorial_path = joinpath(
        REPOSITORY_ROOT,
        "assignments",
        "hw00",
        "julia-tutorial.ipynb",
    )
    homework_path = joinpath(
        REPOSITORY_ROOT,
        "assignments",
        "hw00",
        "hw00.ipynb",
    )

    execute_code_cells(JuliaTutorial, tutorial_path)
    execute_code_cells(HomeworkZero, homework_path)

    @test HomeworkZero.termination_status(HomeworkZero.nonlinear_model) ==
          MOI.LOCALLY_SOLVED
    @test HomeworkZero.x_value ≈ π / 2 atol = 1e-6
    @test HomeworkZero.obj_value ≈ 0.0 atol = 1e-10

    mktempdir() do repository
        mkpath(joinpath(repository, "assignments"))
        cp(
            joinpath(REPOSITORY_ROOT, "assignments", "hw00"),
            joinpath(repository, "assignments", "hw00"),
        )
        destination = AssignmentWorkspace.start_assignment(repository, "hw00")
        @test isfile(joinpath(destination, "README.md"))
        @test isfile(joinpath(destination, "hw00.ipynb"))
        @test isfile(joinpath(destination, "julia-tutorial.ipynb"))
    end
end

module HomeworkTwo end

module HomeworkThree end

@testset "Homework 3 starter notebook and student copy" begin
    source = joinpath(REPOSITORY_ROOT, "assignments", "hw03")
    mktempdir() do repository
        mkpath(joinpath(repository, "assignments"))
        cp(source, joinpath(repository, "assignments", "hw03"))
        @test "hw03" in AssignmentWorkspace.available_assignments(repository)
        destination = AssignmentWorkspace.start_assignment(repository, "hw03")
        notebook = joinpath(destination, "hw03.ipynb")
        for file in ("hw03.ipynb", "README.md")
            @test read(joinpath(destination, file)) == read(joinpath(source, file))
        end
        for directory in (destination, repository)
            cd(directory) do
                execute_code_cells(HomeworkThree, notebook; cell_filename = "In[1]")
            end
        end

        # Updating the template must preserve an existing student's work.
        write(notebook, read(notebook, String) * "\n")
        student_work = read(notebook)
        write(joinpath(repository, "assignments", "hw03", "README.md"), "Updated instructions\n")
        @test_throws ErrorException AssignmentWorkspace.start_assignment(repository, "hw03")
        @test read(notebook) == student_work
        @test read(joinpath(destination, "README.md")) == read(joinpath(source, "README.md"))
    end
end

function check_homework_two_data(example, destination)
    @test example.data_dir == joinpath(destination, "data")
    @test length(example.P) == 5
    @test length(example.C) == 5
    @test length(example.h) == 25
    @test Set(keys(example.h)) ==
          Set((p, c) for p in example.P for c in example.C)
    @test all(example.products.availability .>= 0)
    @test all(example.methods.capacity .>= 0)
    @test all(example.methods.cost .>= 0)
    @test all(isfinite, values(example.h))

    @test example.b == Dict(row.product => row.availability for row in eachrow(example.products))
    @test example.u == Dict(row.method => row.capacity for row in eachrow(example.methods))
    @test example.q == Dict(row.method => row.cost for row in eachrow(example.methods))
end

@testset "Homework 2 starter notebook and student copy" begin
    source = joinpath(REPOSITORY_ROOT, "assignments", "hw02")
    mktempdir() do repository
        mkpath(joinpath(repository, "assignments"))
        cp(source, joinpath(repository, "assignments", "hw02"))
        template = joinpath(repository, "assignments", "hw02", "hw02.ipynb")

        # A kernel at the repository root can also run the published template.
        cd(repository) do
            execute_code_cells(HomeworkTwo, template; cell_filename = "In[1]")
        end
        @test Base.invokelatest(getproperty, HomeworkTwo, :data_dir) ==
              joinpath(dirname(template), "data")

        destination = AssignmentWorkspace.start_assignment(repository, "hw02")
        notebook = joinpath(destination, "hw02.ipynb")
        for file in (
            "hw02.ipynb", "README.md", joinpath("data", "products.csv"),
            joinpath("data", "methods.csv"), joinpath("data", "revenues.csv"),
        )
            @test read(joinpath(destination, file)) == read(joinpath(source, file))
        end
        @test_throws ErrorException AssignmentWorkspace.start_assignment(repository, "hw02")

        for directory in (destination, repository)
            cd(directory) do
                execute_code_cells(HomeworkTwo, notebook; cell_filename = "In[1]")
            end
            # Julia 1.12 notebook evaluation introduces bindings in a new world age.
            Base.invokelatest(check_homework_two_data, HomeworkTwo, destination)
        end

        # Missing student data must not silently fall back to the template.
        rm(joinpath(destination, "data", "products.csv"))
        cd(repository) do
            @test_throws LoadError execute_code_cells(
                HomeworkTwo, notebook; cell_filename = "In[1]",
            )
        end
    end
end
