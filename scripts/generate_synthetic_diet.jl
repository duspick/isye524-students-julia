using CSV
using DataFrames
using Random

const REPOSITORY_ROOT = dirname(abspath(@__DIR__))

function generate_synthetic_diet()
    rng = MersenneTwister(524)
    food_count = 100
    nutrient_count = 20

    adjectives = [
        "Amber", "Azure", "Cosmic", "Crystal", "Dream", "Lunar", "Misty",
        "Nova", "Silver", "Velvet",
    ]
    dishes = [
        "Bites", "Clusters", "Crisps", "Cubes", "Flakes", "Loops", "Nibbles",
        "Puffs", "Swirls", "Twists",
    ]
    foods = ["$(adjective) $(dish)" for adjective in adjectives for dish in dishes]
    nutrients = ["Nutri-$(letter)" for letter in 'A':'T']
    costs = rand(rng, 100:1200, food_count) ./ 100

    amounts = rand(rng, 0:60, nutrient_count, food_count)
    amounts[rand(rng, nutrient_count, food_count) .< 0.55] .= 0
    for i in 1:nutrient_count
        amounts[i, i] = max(amounts[i, i], 10)
    end

    # One serving of each of the first 20 foods is a feasible reference menu.
    # Require only 60% of its nutrient totals, rounded down to whole units.
    reference_totals = vec(sum(amounts[:, 1:nutrient_count]; dims = 2))
    required = floor.(Int, 0.6 .* reference_totals)

    data = DataFrame(
        Nutrient = ["Cost"; nutrients],
        Required = [missing; required],
    )
    for (j, food) in enumerate(foods)
        data[!, food] = [costs[j]; amounts[:, j]]
    end
    return data
end

function main()
    path = joinpath(REPOSITORY_ROOT, "data", "diet-synthetic.csv")
    CSV.write(path, generate_synthetic_diet())
    println("Wrote $(path) (100 foods, 20 nutrients; seed 524).")
end

abspath(PROGRAM_FILE) == abspath(@__FILE__) && main()
