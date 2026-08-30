using Test

const REPOSITORY_ROOT = dirname(@__DIR__)

module AssignmentWorkspace
include(joinpath(@__DIR__, "..", "scripts", "start_assignment.jl"))
end

module PdfExport
include(joinpath(@__DIR__, "..", "scripts", "export_pdf.jl"))
end

@testset "Assignment workspace" begin
    mktempdir() do repository
        source = joinpath(repository, "assignments", "hw01")
        mkpath(joinpath(source, "images"))
        write(joinpath(source, "hw01.ipynb"), "starter notebook")
        write(joinpath(source, "images", "model.png"), "starter image")

        destination = AssignmentWorkspace.start_assignment(repository, "hw01")
        @test read(joinpath(destination, "hw01.ipynb"), String) == "starter notebook"
        @test read(joinpath(destination, "images", "model.png"), String) == "starter image"
        @test_throws ErrorException AssignmentWorkspace.start_assignment(repository, "hw01")
    end
end

@testset "PDF export command" begin
    arguments = PdfExport.quarto_arguments(
        "quarto",
        joinpath(REPOSITORY_ROOT, "student-work", "hw0", "hw0.ipynb"),
        "hw0.pdf",
        false,
    )
    @test "--output-dir" in arguments
    @test PdfExport.SUBMISSIONS_DIR in arguments
    @test "monofont:TeX Gyre Cursor" in arguments
    @test !any(startswith(argument, "latex-output-dir:") for argument in arguments)

    system_arguments = PdfExport.quarto_arguments(
        "quarto",
        "hw0.ipynb",
        "hw0.pdf",
        true,
    )
    @test "latex-tinytex:false" in system_arguments
    @test "latex-auto-install:false" in system_arguments
end
