using Test

using CSV
using DataFrames
using Distributions
using HiGHS
using Ipopt
using JuMP
using NamedArrays
using Plots
using Printf
using XLSX
import MathOptInterface as MOI

const REPOSITORY_ROOT = dirname(@__DIR__)

@testset "ISyE 524 Julia environment" begin
    @test VERSION.major == 1
    @test VERSION.minor == 12
    @test !isnothing(Base.active_project())
    @test realpath(dirname(Base.active_project())) == realpath(REPOSITORY_ROOT)

    model = Model(HiGHS.Optimizer)
    set_silent(model)

    @variable(model, x >= 0)
    @variable(model, y >= 0)
    @constraint(model, 2x + y <= 10)
    @constraint(model, x + 3y <= 12)
    @objective(model, Max, 3x + 4y)

    optimize!(model)

    @test termination_status(model) == MOI.OPTIMAL
    @test objective_value(model) ≈ 22.0 atol = 1e-8
    @test value(x) ≈ 3.6 atol = 1e-8
    @test value(y) ≈ 2.8 atol = 1e-8

    results = DataFrame(
        variable = ["x", "y"],
        value = [value(x), value(y)],
    )
    @test size(results) == (2, 2)

    figure = plot(
        Shape([0.0, 5.0, 3.6, 0.0], [0.0, 0.0, 2.8, 4.0]);
        alpha = 0.25,
        label = "feasible region",
    )
    scatter!(figure, [value(x)], [value(y)]; label = "optimum")
    @test length(figure.series_list) == 2

    @printf(
        "Optimal solution: x = %.1f, y = %.1f, objective = %.1f\n",
        value(x),
        value(y),
        objective_value(model),
    )
end
