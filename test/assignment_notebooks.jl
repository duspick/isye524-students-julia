using JSON
using JuMP
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

function execute_code_cells(module_, path)
    notebook = read_notebook(path)
    code = join(
        join(cell["source"])
        for cell in notebook["cells"]
        if get(cell, "cell_type", nothing) == "code"
    )
    @test !occursin(r"Pkg\.(add|update)\s*\(", code)
    for cell in notebook["cells"]
        get(cell, "cell_type", nothing) == "code" || continue
        Base.include_string(module_, join(cell["source"]), path)
    end
    return module_
end

module JuliaTutorial end
module HomeworkZero end

@testset "Homework 0 starter notebooks" begin
    tutorial_path = joinpath(
        REPOSITORY_ROOT,
        "assignments",
        "hw0",
        "julia-tutorial.ipynb",
    )
    homework_path = joinpath(
        REPOSITORY_ROOT,
        "assignments",
        "hw0",
        "hw0.ipynb",
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
            joinpath(REPOSITORY_ROOT, "assignments", "hw0"),
            joinpath(repository, "assignments", "hw0"),
        )
        destination = AssignmentWorkspace.start_assignment(repository, "hw0")
        @test isfile(joinpath(destination, "README.md"))
        @test isfile(joinpath(destination, "hw0.ipynb"))
        @test isfile(joinpath(destination, "julia-tutorial.ipynb"))
    end
end
