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
