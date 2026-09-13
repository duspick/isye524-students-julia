using JSON
using JuMP
using Test
import MathOptInterface as MOI

const REPOSITORY_ROOT = dirname(@__DIR__)

function execute_code_cells(module_, path; source_replacements = Pair{String,String}[])
    notebook = JSON.parsefile(path)
    @test notebook["nbformat"] == 4
    @test notebook["nbformat_minor"] == 5
    @test notebook["metadata"]["kernelspec"]["name"] == "julia-1.12"
    @test all(cell -> haskey(cell, "id"), notebook["cells"])

    code = join(
        join(cell["source"]) for cell in notebook["cells"]
        if get(cell, "cell_type", nothing) == "code"
    )
    @test !occursin(r"Pkg\.(add|update)\s*\(", code)

    serialized = JSON.json(notebook)
    @test occursin("HiGHS", serialized)
    @test !occursin("SCS", serialized)
    @test !occursin("Clp", serialized)

    for cell in notebook["cells"]
        get(cell, "cell_type", nothing) == "code" || continue
        source = join(cell["source"])
        for replacement in source_replacements
            source = replace(source, replacement)
        end
        Base.include_string(module_, source, path)
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

module CSVDietExample end

module SyntheticDietData
include(joinpath(@__DIR__, "..", "scripts", "generate_synthetic_diet.jl"))
end

@testset "CSV diet class example" begin
    path = joinpath(REPOSITORY_ROOT, "notebooks", "04-McDonaldsDiet-CSV.ipynb")
    # Simulate editing the filename and rerunning all cells in the same kernel.
    # Use both common working directories to check project-relative data paths.
    for (filename, food_count, nutrient_count, directory) in (
        ("mcdonalds.csv", 9, 7, REPOSITORY_ROOT),
        ("diet-synthetic.csv", 100, 20, joinpath(REPOSITORY_ROOT, "notebooks")),
    )
        @testset "$(filename)" begin
            replacements = [
                "dataset_filename = \"mcdonalds.csv\"" =>
                    "dataset_filename = \"$(filename)\"",
            ]
            example = cd(directory) do
                execute_code_cells(
                    CSVDietExample, path; source_replacements = replacements,
                )
            end

            @test example.dataset_filename == filename
            @test example.data_path == joinpath(REPOSITORY_ROOT, "data", filename)
            @test length(example.foods) == food_count
            @test length(example.nutrients) == nutrient_count
            @test size(example.A) == (nutrient_count, food_count)
            @test num_variables(example.model) == food_count
            @test num_constraints(
                example.model; count_variable_in_set_constraints = false,
            ) == nutrient_count
            @test example.status == MOI.OPTIMAL
            @test is_solved_and_feasible(example.model)

            servings = [value(example.x[j]) for j in example.foods]
            costs = [example.cost[j] for j in example.foods]
            minimums = [example.required[i] for i in example.nutrients]
            totals = example.A * servings
            @test all(isfinite, example.A)
            @test all(example.A .>= 0)
            @test all(isfinite, costs)
            @test all(costs .> 0)
            @test all(minimums .> 0)
            @test all(servings .>= -1e-8)
            @test all(totals .>= minimums .- 1e-8)
            @test sum(costs .* servings) ≈ example.minimum_cost atol = 1e-8
            @test example.nutrient_report.total ≈ totals atol = 1e-8
            @test example.nutrient_report.surplus ≈ totals - minimums atol = 1e-8

            if filename == "mcdonalds.csv"
                @test example.minimum_cost ≈ 14.855737704918 atol = 1e-8
                @test example.A == McDonaldsDietExample.A
                @test costs == McDonaldsDietExample.cost_vector
                @test minimums == McDonaldsDietExample.required_vector
            else
                # Check both the published generation recipe and its feasible menu.
                @test isequal(example.df, SyntheticDietData.generate_synthetic_diet())
                reference_totals = vec(sum(example.A[:, 1:20]; dims = 2))
                @test all(reference_totals .>= minimums)
                @test 0 < example.minimum_cost <= sum(costs[1:20]) + 1e-8
            end
        end
    end
end
