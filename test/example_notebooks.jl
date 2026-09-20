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

module DietLPCasesExample end

@testset "Diet LP solution cases" begin
    path = joinpath(REPOSITORY_ROOT, "notebooks", "05-McDonaldsDiet-LPCases.ipynb")
    # Run All must rebuild the models before deleting the drink constraint again.
    for run in 1:2
        @testset "Run All $(run)" begin
            example = execute_code_cells(DietLPCasesExample, path)
            minimums = [example.required[i] for i in example.nutrients]

            @test example.A == McDonaldsDietExample.A
            @test example.unbounded_status in (
                MOI.DUAL_INFEASIBLE, MOI.INFEASIBLE_OR_UNBOUNDED,
            )
            @test !is_solved_and_feasible(example.unbounded_model)
            # Validate the feasible menu and improving direction used in the text.
            @test all(example.A * fill(10.0, length(example.foods)) .>= minimums)
            @test all(example.A_NA[:, :QP] .>= 0)
            @test :QP in example.burgers

            @test example.bounded_status == MOI.OPTIMAL
            @test is_solved_and_feasible(example.bounded_model)
            @test example.maximum_burgers ≈ 30.0 atol = 1e-8
            bounded_servings = [value(example.x_bounded[j]) for j in example.foods]
            @test all(bounded_servings .>= -1e-8)
            @test all(bounded_servings .<= 10.0 + 1e-8)
            @test all(example.A * bounded_servings .>= minimums .- 1e-8)

            # This status was saved before the same model's drink limit changed.
            @test example.infeasible_status == MOI.INFEASIBLE
            @test example.relaxed_status == MOI.OPTIMAL
            @test is_solved_and_feasible(example.limited_model)
            @test example.extra_drinks ≈ 16.9 atol = 1e-8
            @test value(example.s) ≈ example.extra_drinks atol = 1e-8
            @test example.total_drinks ≈ 3.0 + example.extra_drinks atol = 1e-8

            relaxed_servings = [value(example.x_limited[j]) for j in example.foods]
            @test all(relaxed_servings .>= -1e-8)
            @test all(example.A * relaxed_servings .>= minimums .- 1e-8)
            @test sum(value(example.x_limited[j]) for j in example.sandwiches) <= 3.0 + 1e-8
            @test value(example.x_limited[:FR]) <= 2.0 + 1e-8
        end
    end
end

module AlloyExample end

@testset "Alloy blending class example" begin
    path = joinpath(REPOSITORY_ROOT, "notebooks", "06-Alloy.ipynb")
    example = execute_code_cells(AlloyExample, path)

    @test example.status == MOI.OPTIMAL
    @test is_solved_and_feasible(example.model)
    @test example.total_production ≈ 500.0 atol = 1e-8
    @test example.minimum_cost ≈ 98_121.63579168124 atol = 1e-6

    amounts = [value(example.x[r]) for r in example.raw]
    stock = [example.availability[r] for r in example.raw]
    costs = [example.cost[r] for r in example.raw]
    @test all(amounts .>= -1e-8)
    @test all(amounts .<= stock .+ 1e-8)
    @test sum(amounts) >= example.demand - 1e-8
    @test sum(amounts) ≈ example.total_production atol = 1e-8
    @test sum(costs .* amounts) ≈ example.minimum_cost atol = 1e-6
    @test [example.remaining_stock[r] for r in example.raw] ≈ stock - amounts atol = 1e-8

    # Recompute weighted percentages from the numerical matrix, including both limits.
    grades = transpose(example.composition) * amounts / sum(amounts)
    minimums = [example.minimum_grade[e] for e in example.elements]
    maximums = [example.maximum_grade[e] for e in example.elements]
    @test all(grades .>= minimums .- 1e-8)
    @test all(grades .<= maximums .+ 1e-8)
    @test [example.final_grade[e] for e in example.elements] ≈ grades atol = 1e-8
    # The original upper-bound typo incorrectly forced copper to its minimum.
    @test example.final_grade[:Cu] ≈ 0.6 atol = 1e-8
    @test example.final_grade[:Cu] > example.minimum_grade[:Cu] + 1e-8
end

module BlendingExample end

@testset "Gasoline blending class example" begin
    path = joinpath(REPOSITORY_ROOT, "notebooks", "07-Blending.ipynb")
    example = execute_code_cells(BlendingExample, path)

    @test example.status == MOI.OPTIMAL
    @test is_solved_and_feasible(example.model)
    @test example.maximum_profit ≈ 318_100.0 atol = 1e-6

    allocations = [value(example.x[i, j]) for i in example.crudes, j in example.gases]
    purchases = [value(example.y[i]) for i in example.crudes]
    sales = [value(example.z[j]) for j in example.gases]
    advertising = [value(example.a[j]) for j in example.gases]
    @test all(allocations .>= -1e-8)
    @test all(purchases .>= -1e-8)
    @test all(sales .>= -1e-8)
    @test all(advertising .>= -1e-8)
    @test vec(sum(allocations; dims = 2)) ≈ purchases atol = 1e-8
    @test vec(sum(allocations; dims = 1)) ≈ sales atol = 1e-8
    @test all(purchases .<= example.max_crude_available + 1e-8)
    @test sum(purchases) <= example.max_crude_processed + 1e-8
    @test example.total_processed ≈ sum(purchases) atol = 1e-8

    nominal_demand = [example.gas_nom_demand[j] for j in example.gases]
    @test all(sales .<= nominal_demand .+ example.advertising_inc .* advertising .+ 1e-8)
    @test advertising ≈ max.(sales - nominal_demand, 0) / example.advertising_inc atol = 1e-8

    revenue = sum(example.gas_price[j] * value(example.z[j]) for j in example.gases)
    crude_cost = sum(example.crude_price[i] * value(example.y[i]) for i in example.crudes)
    processing_cost = example.processing_cost_per_barrel * sum(purchases)
    @test example.daily_revenue ≈ revenue atol = 1e-6
    @test example.daily_crude_cost ≈ crude_cost atol = 1e-6
    @test example.daily_processing_cost ≈ processing_cost atol = 1e-6
    @test example.daily_advertising_cost ≈ sum(advertising) atol = 1e-8
    @test example.maximum_profit ≈ revenue - crude_cost - processing_cost - sum(advertising) atol = 1e-6

    for j in example.gases
        volume = value(example.z[j])
        octane_total = sum(example.octane[i] * value(example.x[i, j]) for i in example.crudes)
        sulfur_total = sum(example.sulfur[i] * value(example.x[i, j]) for i in example.crudes)
        @test octane_total >= example.min_octane[j] * volume - 1e-8
        @test sulfur_total <= example.max_sulfur[j] * volume + 1e-8
        if volume > 1e-6
            @test example.blend_octane[j] ≈ octane_total / volume atol = 1e-8
            @test example.blend_sulfur[j] ≈ sulfur_total / volume atol = 1e-8
        else
            @test !haskey(example.blend_octane, j)
            @test !haskey(example.blend_sulfur, j)
        end
    end

    @testset "Higher processing charge and zero production" begin
        # Changing the input must affect the objective when Run All rebuilds the model.
        example = execute_code_cells(BlendingExample, path; source_replacements = [
            "processing_cost_per_barrel = 4" => "processing_cost_per_barrel = 100",
        ])
        @test example.status == MOI.OPTIMAL
        @test is_solved_and_feasible(example.model)
        @test example.maximum_profit ≈ 0.0 atol = 1e-8
        @test example.total_processed ≈ 0.0 atol = 1e-8
        @test all(abs(value(example.z[j])) <= 1e-8 for j in example.gases)
        @test all(abs(value(example.a[j])) <= 1e-8 for j in example.gases)
        @test isempty(example.produced_gases)
        @test isempty(example.blend_octane)
        @test isempty(example.blend_sulfur)
    end
end

function check_shoeco_plan(example; backlog = false)
    @test example.status == MOI.OPTIMAL
    @test is_solved_and_feasible(example.model)
    plan = example.plan
    @test plan.month == collect(example.months)
    @test plan.demand == example.d
    for (column, variables) in (
        (plan.produced, example.x), (plan.workers, example.w),
        (plan.hired, example.h), (plan.fired, example.f),
        (plan.overtime_hours, example.o),
    )
        @test column ≈ value.(variables) atol = 1e-8
        @test all(column .>= -1e-8)
    end

    # Cumulative production and staffing changes must explain each month's state.
    net_inventory = example.initial_inventory .+ cumsum(plan.produced - plan.demand)
    @test value.(example.i) ≈ net_inventory atol = 1e-8
    @test plan.workers ≈ example.initial_workforce .+ cumsum(plan.hired - plan.fired) atol = 1e-8
    @test all(example.labor_hours_per_pair .* plan.produced .<=
        example.regular_hours_per_worker .* plan.workers .+ plan.overtime_hours .+ 1e-8)
    @test all(plan.overtime_hours .<=
        example.overtime_hours_per_worker .* plan.workers .+ 1e-8)
    @test all(plan.inventory .>= -1e-8)

    costs = [
        example.material_cost * sum(plan.produced),
        example.wage_cost * sum(plan.workers),
        example.overtime_cost * sum(plan.overtime_hours),
        example.hiring_cost * sum(plan.hired),
        example.firing_cost * sum(plan.fired),
        example.holding_cost * sum(plan.inventory),
    ]
    if backlog
        @test plan.net_inventory ≈ net_inventory atol = 1e-8
        @test plan.inventory ≈ value.(example.L) atol = 1e-8
        @test plan.backlog ≈ value.(example.S) atol = 1e-8
        @test all(plan.backlog .>= -1e-8)
        @test plan.inventory ≈ max.(net_inventory, 0) atol = 1e-8
        @test plan.backlog ≈ max.(-net_inventory, 0) atol = 1e-8
        @test last(plan.backlog) ≈ 0.0 atol = 1e-8
        push!(costs, example.backlog_cost * sum(plan.backlog))
    else
        @test plan.inventory ≈ net_inventory atol = 1e-8
    end
    @test last(net_inventory) >= -1e-8
    @test example.cost_report.dollars ≈ costs atol = 1e-6
    @test sum(costs) ≈ example.minimum_cost atol = 1e-6
end

module ShoeCoExample end

@testset "ShoeCo production planning class example" begin
    path = joinpath(REPOSITORY_ROOT, "notebooks", "08-ShoeCo.ipynb")
    example = execute_code_cells(ShoeCoExample, path)
    check_shoeco_plan(example)
    @test example.minimum_cost ≈ 692_500.0 atol = 1e-6
    @test sum(example.plan.produced) ≈ 10_500.0 atol = 1e-8
    @test last(example.plan.inventory) ≈ 0.0 atol = 1e-8

    @testset "Lower overtime rate" begin
        # The default plan uses no overtime. Exercise its cost and capacity here,
        # also checking that Run All rebuilds the model in the same kernel.
        example = execute_code_cells(ShoeCoExample, path; source_replacements = [
            "overtime_cost = 13" => "overtime_cost = 1",
        ])
        check_shoeco_plan(example)
        @test sum(example.plan.overtime_hours) > 1e-8
        @test example.minimum_cost < 692_500.0
    end
end

module ShoeCoBacklogExample end

@testset "ShoeCo backlog class example" begin
    path = joinpath(REPOSITORY_ROOT, "notebooks", "09-ShoeCo-backlog.ipynb")
    example = execute_code_cells(ShoeCoBacklogExample, path)
    check_shoeco_plan(example; backlog = true)
    @test example.minimum_cost ≈ 690_000.0 atol = 1e-6
    @test example.plan.backlog ≈ [0.0, 0.0, 500.0, 0.0] atol = 1e-8
    @test sum(example.plan.produced) ≈ 10_500.0 atol = 1e-8
    @test last(example.plan.inventory) ≈ 0.0 atol = 1e-8

    @testset "Backlog penalty $(penalty)" for penalty in (100, 0)
        example = execute_code_cells(ShoeCoBacklogExample, path; source_replacements = [
            "backlog_cost = 20" => "backlog_cost = $(penalty)",
        ])
        check_shoeco_plan(example; backlog = true)
        if penalty == 100
            # An expensive backlog recovers the cost of the on-time plan.
            @test example.minimum_cost ≈ 692_500.0 atol = 1e-6
            @test all(abs.(example.plan.backlog) .<= 1e-8)
        else
            # Even free backlog must be cleared by the end of the horizon.
            @test example.minimum_cost <= 690_000.0 + 1e-6
            @test sum(example.plan.produced) ≈ 10_500.0 atol = 1e-8
        end
    end
end
