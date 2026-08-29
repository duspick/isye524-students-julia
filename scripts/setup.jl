import Pkg

const REPOSITORY_ROOT = dirname(abspath(@__DIR__))
const SUPPORTED_JULIA = v"1.12"

function check_julia_version()
    if VERSION.major != SUPPORTED_JULIA.major ||
       VERSION.minor != SUPPORTED_JULIA.minor
        error(
            "ISyE 524 requires Julia 1.12.x, but this task is running Julia " *
            "$(VERSION). Install and select the 1.12 channel with Juliaup.",
        )
    end
end

function main()
    check_julia_version()

    println("ISyE 524 repository: ", REPOSITORY_ROOT)
    println("Julia version: ", VERSION)
    println("Activating the course environment...")

    Pkg.activate(REPOSITORY_ROOT)
    Pkg.instantiate()
    Pkg.precompile()

    println()
    println("ISyE 524 Julia environment is ready.")
    println("Active project: ", Base.active_project())
end

main()
