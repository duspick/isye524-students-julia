using JSON
using JuMP
using Test
import MathOptInterface as MOI

const REPOSITORY_ROOT = dirname(@__DIR__)

function execute_code_cells(module_, path)
    notebook = JSON.parsefile(path)
    @test notebook["nbformat"] == 4
    @test notebook["nbformat_minor"] == 5
    @test notebook["metadata"]["kernelspec"]["name"] == "julia-1.12"

    serialized = JSON.json(notebook)
    @test occursin("HiGHS", serialized)
    @test !occursin("SCS", serialized)
    @test !occursin("Clp", serialized)

    for cell in notebook["cells"]
        get(cell, "cell_type", nothing) == "code" || continue
        Base.include_string(module_, join(cell["source"]), path)
    end
    return module_
end

module TopBrassExample end

@testset "Top Brass class example" begin
    path = joinpath(REPOSITORY_ROOT, "notebooks", "01-TopBrass-Intro.ipynb")
    execute_code_cells(TopBrassExample, path)

    @test TopBrassExample.status == MOI.OPTIMAL
    @test TopBrassExample.football_value ≈ 650.0 atol = 1e-8
    @test TopBrassExample.soccer_value ≈ 1100.0 atol = 1e-8
    @test TopBrassExample.profit_value ≈ 17_700.0 atol = 1e-8
end

module TopBrassFullExample end

@testset "Top Brass indexed class example" begin
    path = joinpath(REPOSITORY_ROOT, "notebooks", "02-TopBrass-Full.ipynb")
    execute_code_cells(TopBrassFullExample, path)

    for model in (
        TopBrassFullExample.literal_model,
        TopBrassFullExample.bounded_model,
        TopBrassFullExample.indexed_model,
        TopBrassFullExample.resource_model,
    )
        @test termination_status(model) == MOI.OPTIMAL
        @test objective_value(model) ≈ 17_700.0 atol = 1e-8
    end
    @test termination_status(TopBrassFullExample.scenario_model) == MOI.OPTIMAL
    @test TopBrassFullExample.scenario_profit ≈ 18_000.0 atol = 1e-8
end

module McDonaldsDietExample end

@testset "McDonald's diet class example" begin
    path = joinpath(REPOSITORY_ROOT, "notebooks", "03-McDonaldsDiet.ipynb")
    example = execute_code_cells(McDonaldsDietExample, path)

    @test example.named_status == MOI.OPTIMAL
    @test example.indexed_status == MOI.OPTIMAL
    @test is_solved_and_feasible(example.named_model)
    @test is_solved_and_feasible(example.indexed_model)
    @test example.named_cost ≈ 14.855737704918 atol = 1e-8
    @test example.named_cost ≈ example.indexed_cost atol = 1e-8

    for servings in (
        [value(example.x_named[j]) for j in example.foods],
        value.(example.x_indexed),
    )
        @test all(servings .>= -1e-8)
        @test all(example.A * servings .>= example.required_vector .- 1e-8)
        @test sum(example.cost_vector .* servings) ≈ example.named_cost atol = 1e-8
    end
end
