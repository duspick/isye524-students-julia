using JSON
using Test

module NotebookHygiene
include(joinpath(@__DIR__, "..", "scripts", "notebook_hygiene.jl"))
end

const ATTACHMENT_DATA = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="

function dirty_notebook()
    return JSON.parse("""
    {
     "cells": [
      {
       "cell_type": "markdown",
       "id": "model-image",
       "metadata": {},
       "attachments": {
        "model.png": {
         "image/png": "$(ATTACHMENT_DATA)"
        }
       },
       "source": ["![Handwritten model](attachment:model.png)"]
      },
      {
       "cell_type": "code",
       "execution_count": 4,
       "id": "calculation",
       "metadata": {
        "execution": {
         "iopub.status.busy": "2026-08-29T12:00:00Z"
        }
       },
       "outputs": [
        {
         "name": "stdout",
         "output_type": "stream",
         "text": ["answer = 42\\n"]
        }
       ],
       "source": ["println(\\\"answer = 42\\\")"]
      }
     ],
     "metadata": {
      "kernelspec": {
       "display_name": "Julia 1.12",
       "language": "julia",
       "name": "julia-1.12"
      },
      "widgets": {
       "application/vnd.jupyter.widget-state+json": {}
      }
     },
     "nbformat": 4,
     "nbformat_minor": 5
    }
    """)
end

@testset "Notebook hygiene" begin
    mktempdir() do directory
        path = joinpath(directory, "with-attachment.ipynb")
        open(path, "w") do io
            JSON.print(io, dirty_notebook(), 1)
            write(io, '\n')
        end

        before = JSON.parsefile(path)
        attachment_before = JSON.json(before["cells"][1]["attachments"])
        source_before = copy(before["cells"][1]["source"])

        @test length(NotebookHygiene.notebook_issues(before)) == 4
        @test NotebookHygiene.clean_notebook(path)

        after = JSON.parsefile(path)
        code_cell = after["cells"][2]
        @test isempty(code_cell["outputs"])
        @test isnothing(code_cell["execution_count"])
        @test !haskey(code_cell["metadata"], "execution")
        @test !haskey(after["metadata"], "widgets")
        @test JSON.json(after["cells"][1]["attachments"]) == attachment_before
        @test after["cells"][1]["source"] == source_before
        @test after["metadata"]["kernelspec"]["name"] == "julia-1.12"
        @test isempty(NotebookHygiene.notebook_issues(after))

        cleaned_once = read(path, String)
        @test !NotebookHygiene.clean_notebook(path)
        @test read(path, String) == cleaned_once
    end
end

@testset "Notebook discovery exclusions" begin
    mktempdir() do repository
        tracked_directory = joinpath(repository, "assignments", "hw01")
        ignored_directory = joinpath(repository, "student-work", "hw01")
        mkpath(tracked_directory)
        mkpath(ignored_directory)
        write(joinpath(tracked_directory, "hw01.ipynb"), "{}")
        write(joinpath(ignored_directory, "hw01.ipynb"), "{}")

        discovered = NotebookHygiene.discover_notebooks(repository)
        @test discovered == [joinpath(tracked_directory, "hw01.ipynb")]
    end
end
