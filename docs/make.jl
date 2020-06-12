using Documenter, MRC

makedocs(
    modules = [MRC],
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    authors = "Seth Axen",
    sitename = "MRC.jl",
    pages = Any[
        "index.md",
        "api.md",
    ]
    # strict = true,
    # clean = true,
    # checkdocs = :exports,
)

deploydocs(
    repo = "github.com/sethaxen/MRC.jl.git",
    push_preview = true
)
